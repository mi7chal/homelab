# Diagnoza Traefik — restarty i obecna niedostępność

> [!IMPORTANT]
> Ten dokument zawiera pełną diagnozę przeprowadzoną 2026-03-22 ~21:00-21:23 CET. Służy jako punkt wyjścia do kontynuacji w nowej rozmowie.

## Stan klastra

- **K3s v1.34.3** na Debianie 13 (trixie)
- 2 node'y:
  - `gg3-k8s-control-pane` (192.168.0.31) — 3 CPU, 10 GiB RAM, Intel iGPU, **54 pody**
  - `raspberrypi5` (192.168.0.10) — 4 CPU, ~4 GiB RAM, **29 podów**
- Flux CD do GitOps, Longhorn jako storage, MetalLB jako LoadBalancer (Layer2)

## Dwa odrębne problemy

### Problem 1: Restarty Traefika (i wielu innych podów)

| Fakt | Dowód |
|---|---|
| Traefik: 30 restartów w 17 dni | `kubectl get pods -n traefik-system` |
| Traefik zużywa tylko **60Mi** RAM | `kubectl top pod` — limit 500Mi NIE jest przyczyną |
| Exit Code: **255**, Reason: **Unknown** | `kubectl describe pod` — to nie jest OOMKill (byłoby 137) |
| Logi pokazują graceful shutdown: `"I have to go..."` | Pod dostaje SIGTERM/SIGKILL z zewnątrz |
| **Masowe restarty wielu podów jednocześnie** | Eventy pokazują 7 podów zabitych w tym samym momencie (authentik, flux controllers, nfd, cloudflared) — wszystkie "failed liveness probe" |
| Longhorn ma **100-279 restartów** na pody | Największa niestabilność w klastrze |
| Longhorn manager loguje ciągłe flappowanie rpi5 | `"Node raspberrypi5 is down"` → `"is ready"` co kilkadziesiąt sekund |
| Longhorn nie może znaleźć storage path | `"cannot find device path of /var/lib/longhorn"` na control-pane |
| Memory limits overcommit na control-pane: **148%** | Suma limitów = 14.7 GiB przy 10 GiB RAM |
| Wiele podów (Longhorn, MetalLB, postgres, etc.) **nie ma żadnych limitów ani requestów** | `kubectl get pods` z parsowaniem resources |
| DiskPressure transition na control-pane: **20 marca** | `kubectl describe node` |

**Wniosek**: Restarty nie są specyficzne dla Traefika. Control-pane node jest przeciążony (54 pody, overcommit pamięci, Longhorn generuje ciężki I/O), co powoduje, że kubelet nie zdąża odpytywać liveness probe'ów i masowo restartuje pody.

**Hipoteza do zweryfikowania**: Longhorn jest głównym destabilizatorem — ciągłe flappowanie node'ów, nieznaleziony storage path, i duże I/O saturują dysk.

### Problem 2: Traefik aktualnie niedostępny (AKTYWNY w momencie diagnozy)

| Fakt | Dowód |
|---|---|
| Traefik pod jest Running 1/1, ping OK | `kubectl exec ... wget ... /ping` → "OK" |
| Traefik endpoint istnieje | `10.42.0.245:8000, 10.42.0.245:8443` |
| **NodePort 31413 na 192.168.0.31 DZIAŁA** | `nc -z -w 5 192.168.0.31 31413` → succeeded |
| **VIP 192.168.0.32 NIE odpowiada** — ani ping, ani porty | `ping` timeout, `nc` timeout |
| **Brak ARP entry** dla 192.168.0.32 | `arp -a` nie zwraca wyniku dla tego IP |
| MetalLB speaker na control-pane milczy od 19:53 | Logi speakera kończą się na 19:53 |
| MetalLB speaker na rpi5 miał probe failures 30 min temu | Event: `Liveness probe failed: EOF` |
| MetalLB serwis poprawnie skonfigurowany | `home-pool: 192.168.0.32-192.168.0.32`, L2 advertisement OK |

**Wniosek**: Traefik działa poprawnie. Problem jest w **MetalLB** — speaker na control-pane (który jest odpowiedzialny za ogłaszanie VIP 192.168.0.32 przez gratuitous ARP) przestał wysyłać ARP announcements. Bez ARP, sieć nie wie, że 192.168.0.32 jest osiągalny na MAC adresie control-pane.

## Zmiany już wprowadzone w repo

W pliku [traefik.yaml](file:///Users/michal/Development/homelab_repo/k8s/infrastructure/controllers/traefik/traefik.yaml):

```diff
 readinessProbe:
-  failureThreshold: 5
+  failureThreshold: 10
   timeoutSeconds: 5
-  initialDelaySeconds: 10
+  initialDelaySeconds: 20
 livenessProbe:
-  failureThreshold: 5
+  failureThreshold: 10
   timeoutSeconds: 5
-  initialDelaySeconds: 10
+  initialDelaySeconds: 20
```

Pamięć requests/limits **nie zmieniona** (cofnięto wcześniejszą zmianę) — bo Traefik zużywa tylko 60Mi.

## Co dalej — następne kroki

### Natychmiastowe (przywrócenie dostępności):
1. **Restart MetalLB speakera na control-pane**: `kubectl delete pod metallb-system-metallb-speaker-4789r -n metallb-system` — to wymusi re-announcement VIP
2. Sprawdzić, czy po restarcie `ping 192.168.0.32` zaczyna działać
3. Sprawdzić, czy `curl -sk https://192.168.0.32` zwraca odpowiedź Traefika

### Diagnostyka głównej przyczyny restartów:
1. **Longhorn**: Zbadać dlaczego `/var/lib/longhorn` nie jest poprawnie zamontowany na control-pane, i dlaczego rpi5 ciągle flappuje
2. **Longhorn logi**: `kubectl logs -n longhorn-system longhorn-manager-4rkgq --since=1h` — szukać error/warning
3. **Dysk na node**: SSH na control-pane → `df -h`, `iostat`, `dmesg | tail -100` — szukać I/O errors
4. **Rozważyć usunięcie memory limitów** z podów, które ich nie potrzebują (homelab pattern) — zmniejszy to ryzyko OOMKill i zlikwiduje overcommit
5. **MetalLB stabilność**: Speaker ma 128 restartów — ten sam problem co Traefik (liveness probe failures podczas spowolnień node'a). Rozważyć podniesienie tolerancji probe'y MetalLB.

## Kluczowe pliki w repo

| Plik | Opis |
|---|---|
| [traefik.yaml](file:///Users/michal/Development/homelab_repo/k8s/infrastructure/controllers/traefik/traefik.yaml) | HelmRelease Traefika — chart 38.0.2, namespace traefik-system |
| [traefik-auth.yaml](file:///Users/michal/Development/homelab_repo/k8s/infrastructure/configs/traefik/traefik-auth.yaml) | ForwardAuth middleware → Authentik outpost |
| [traefik-ingressroutes.yaml](file:///Users/michal/Development/homelab_repo/k8s/infrastructure/configs/traefik/traefik-ingressroutes.yaml) | IngressRoutes do external services (proxmox, HA, portainer, adguard, qnap) |
| [repositories.yaml](file:///Users/michal/Development/homelab_repo/k8s/flux-system/repositories.yaml) | HelmRepositories — traefik repo z interval 24h |
| [cert-manager-issuer.yaml](file:///Users/michal/Development/homelab_repo/k8s/infrastructure/services/cert-manager-issuer/cert-manager-issuer.yaml) | ClusterIssuer + wildcard Certificate (traefik-system) |

## Łańcuch zależności Flux

```
infrastructure-controllers (traefik, cert-manager, metallb, longhorn, ...)
  → infrastructure-configs (traefik IngressRoutes, metallb pools, longhorn config)
    → infrastructure-services (cert-manager issuer + Certificate, databases)
      → apps (fileflows, jellyseerr, maintainerr, n8n, media-stack, ...)
```
