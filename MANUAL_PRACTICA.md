# 📘 Manual de Práctica — Arquitectura GitOps sobre Kubernetes

## Información Académica

| Campo | Detalle |
|---|---|
| **Estudiante** | Jhon Edison Hincapie Garcia |
| **Programa** | Maestría en Arquitectura de Software |
| **Institución** | Politécnico Grancolombiano |
| **Rol profesional** | Arquitecto de Software en AutoTrust CO |
| **Módulo** | Contenerización de Aplicaciones |
| **Unidad** | Unidad 3 — Orquestación de Contenedores |
| **Actividad** | Actividad Formativa — Rúbrica de Excelencia |

---

## Objetivo de la Práctica

Desplegar una aplicación web estática bajo el patrón arquitectónico **GitOps** utilizando un clúster real de **Kubernetes** en **Killercoda** y **Argo CD** como orquestador de entrega continua, demostrando:

- ✅ Despliegue declarativo desde un repositorio Git (fuente de verdad)
- ✅ Sincronización automática con Argo CD (auto-sync + selfHeal)
- ✅ Alta disponibilidad con 3 réplicas
- ✅ Auto-curación (Self-Healing) ante fallos de Pods

---

## Arquitectura de la Solución

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────────────┐
│   Desarrollador  │      │     GitHub        │      │   Clúster Kubernetes    │
│                  │      │   (Fuente de      │      │     (Killercoda)        │
│  git push ──────────────▶   Verdad)         │      │                         │
│                  │      │                   │      │  ┌───────────────────┐  │
│                  │      │  manifests/       │◀─────│  │    Argo CD        │  │
│                  │      │    app.yaml       │ poll │  │  (namespace:      │  │
│                  │      │                   │      │  │   argocd)         │  │
│                  │      │  app/             │      │  │  NodePort: 30007  │  │
│                  │      │    index.html     │      │  └────────┬──────────┘  │
│                  │      │                   │      │           │ sync        │
│                  │      │  setup-           │      │  ┌────────▼──────────┐  │
│                  │      │   killercoda.sh   │      │  │   Deployment      │  │
│                  │      │                   │      │  │   (3 réplicas)    │  │
│                  │      └───────────────────┘      │  │   nginx:alpine    │  │
│                  │                                 │  └────────┬──────────┘  │
│                  │                                 │  ┌────────▼──────────┐  │
│                  │                                 │  │   Service         │  │
│  Navegador ◀──────────────────────────────────────────│  NodePort: 32000  │  │
│                  │                                 │  └───────────────────┘  │
└─────────────────┘                                 └─────────────────────────┘
```

---

## Estructura del Repositorio

```text
gke-gitops-autotrust/
│
├── app/
│   └── index.html              # Sitio web estático (Tailwind CSS vía CDN)
│
├── manifests/
│   └── app.yaml                # Manifiesto K8s unificado (ConfigMap + Deployment + Service)
│
├── setup-killercoda.sh         # Script Bash automatizado para Killercoda
│
└── MANUAL_PRACTICA.md          # ← Este archivo
```

---

## Prerrequisitos

| Herramienta | Descripción |
|---|---|
| **Cuenta GitHub** | Para alojar el repositorio público |
| **Navegador web** | Chrome, Firefox o Edge |
| **Killercoda** | Acceso gratuito en [killercoda.com](https://killercoda.com) |

> 💡 **No necesitas instalar nada** en tu computador local. Todo se ejecuta directamente en el entorno de Killercoda.

---

## Paso a Paso Completo

### FASE 1 — Preparación del Repositorio en GitHub

#### Paso 1.1: Crear el repositorio en GitHub

1. Ir a [github.com/new](https://github.com/new)
2. Configurar:
   - **Nombre:** `gke-gitops-autotrust`
   - **Visibilidad:** `Public` ⚠️ (obligatorio para que Argo CD pueda clonarlo)
   - **Inicializar con README:** No (ya tenemos los archivos)
3. Clic en **"Create repository"**

#### Paso 1.2: Subir los archivos al repositorio

Desde la terminal local (tu computador), ejecutar:

```bash
# Si aún no has clonado el repositorio:
cd ~/Documents/GIT/gke-gitops-autotrust

# Agregar el remote de GitHub (si no existe)
git remote add origin https://github.com/jhoney787813/gke-gitops-autotrust.git

# Agregar todos los archivos, hacer commit y push
git add .
git commit -m "feat: estructura GitOps completa - ConfigMap + Deployment + Service + Script Killercoda"
git push -u origin main
```

#### Paso 1.3: Verificar en GitHub

Abrir en el navegador:
```
https://github.com/jhoney787813/gke-gitops-autotrust
```

Confirmar que se ven los archivos:
- ✅ `app/index.html`
- ✅ `manifests/app.yaml`
- ✅ `setup-killercoda.sh`

---

### FASE 2 — Configuración del Entorno en Killercoda

#### Paso 2.1: Abrir Killercoda

1. Ir a [killercoda.com](https://killercoda.com)
2. Iniciar sesión (cuenta gratuita con GitHub o Google)
3. Navegar a: **Playgrounds → Kubernetes**
4. Clic en **"Start"** para lanzar el escenario

> ⏳ Esperar ~30 segundos a que el entorno cargue. Verás una terminal lista cuando aparezca el prompt `$` o `controlplane $`.

#### Paso 2.2: Verificar que Kubernetes está activo

En la terminal de Killercoda, ejecutar:

```bash
kubectl cluster-info
```

**Resultado esperado:**
```
Kubernetes control plane is running at https://172.30.1.2:6443
CoreDNS is running at https://172.30.1.2:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

También verificar los nodos:
```bash
kubectl get nodes
```

**Resultado esperado:**
```
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   XX    v1.30.X
```

---

### FASE 3 — Ejecución del Script de Configuración

#### Paso 3.1: Clonar el repositorio en Killercoda

En la terminal de Killercoda:

```bash
git clone https://github.com/jhoney787813/gke-gitops-autotrust.git
```

**Resultado esperado:**
```
Cloning into 'gke-gitops-autotrust'...
remote: Enumerating objects: XX, done.
...
```

#### Paso 3.2: Entrar al directorio del proyecto

```bash
cd gke-gitops-autotrust
```

#### Paso 3.3: Dar permisos de ejecución al script

```bash
chmod +x setup-killercoda.sh
```

#### Paso 3.4: Ejecutar el script de configuración

```bash
./setup-killercoda.sh
```

> ⏳ **Tiempo estimado: 2 a 4 minutos.** El script mostrará progreso con barras de colores.

**Lo que hace el script automáticamente:**

| Paso | Acción | Qué verás en pantalla |
|---|---|---|
| 1/5 | Instala Argo CD | `✔ Argo CD instalado en el namespace 'argocd'` |
| 2/5 | Espera que los Pods estén listos | `✔ Argo CD Server está disponible` |
| 3/5 | Expone Argo CD en puerto 30007 | `✔ Argo CD accesible en el puerto 30007` |
| 4/5 | Obtiene la contraseña admin | `✔ Credenciales obtenidas` |
| 5/5 | Crea la Application GitOps | `✔ Application 'autotrust-web' creada` |

**Al finalizar, el script muestra un resumen como este:**

```
══════════════════════════════════════════════════════════
  ✅  ¡ENTORNO GitOps CONFIGURADO EXITOSAMENTE!
══════════════════════════════════════════════════════════

  Argo CD UI:
    URL:       https://<KILLERCODA_HOST>:30007
    Usuario:   admin
    Contraseña: <se muestra aquí>

  Aplicación Web:
    URL:       http://<KILLERCODA_HOST>:32000
```

> ⚠️ **IMPORTANTE:** Copiar la contraseña mostrada, la necesitarás para acceder a Argo CD.

---

### FASE 4 — Verificación del Despliegue

#### Paso 4.1: Verificar los Pods (3 réplicas)

```bash
kubectl get pods -l app=static-web
```

**Resultado esperado (3 pods Running):**
```
NAME                                     READY   STATUS    RESTARTS   AGE
static-web-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
static-web-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
static-web-deployment-xxxxxxxxxx-xxxxx   1/1     Running   0          1m
```

#### Paso 4.2: Verificar el Service

```bash
kubectl get svc static-web-service
```

**Resultado esperado:**
```
NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
static-web-service   NodePort   10.96.xxx.xxx   <none>        80:32000/TCP   1m
```

#### Paso 4.3: Verificar la Application de Argo CD

```bash
kubectl get applications -n argocd
```

**Resultado esperado:**
```
NAME             SYNC STATUS   HEALTH STATUS
autotrust-web    Synced        Healthy
```

#### Paso 4.4: Ver todos los recursos desplegados

```bash
kubectl get all -l app=static-web
```

---

### FASE 5 — Acceso a los Servicios desde el Navegador

#### Paso 5.1: Acceder a la Aplicación Web (Puerto 32000)

En Killercoda, hay **dos formas** de acceder a un NodePort:

**Opción A — Botón de Puerto (recomendado):**
1. En la parte superior de la terminal de Killercoda, buscar el ícono 🔗 o el botón **"Traffic Port"** / **"Port"**
2. Escribir: `32000`
3. Clic en **"Access"** o presionar Enter
4. Se abrirá una nueva pestaña con la aplicación web

**Opción B — Desde la terminal:**
```bash
# Obtener la URL directa
echo "http://$(hostname -I | awk '{print $1}'):32000"
```

> ✅ Deberías ver el sitio web de AutoTrust CO con el diseño dark-mode, las tarjetas del flujo GitOps y la tarjeta de autoría.

#### Paso 5.2: Acceder a Argo CD (Puerto 30007)

1. Usar el botón **"Traffic Port"** → escribir `30007`
2. Se abrirá el login de Argo CD
3. Ingresar las credenciales:
   - **Username:** `admin`
   - **Password:** La que mostró el script en el Paso 3.4

> ✅ En el dashboard de Argo CD deberías ver la Application **"autotrust-web"** con estado **"Synced"** y **"Healthy"** en verde.

---

### FASE 6 — Demostración de Self-Healing (Auto-curación)

Esta fase demuestra que Kubernetes recrea automáticamente los Pods cuando se eliminan, gracias a las 3 réplicas configuradas en el Deployment.

#### Paso 6.1: Ver los Pods actuales

```bash
kubectl get pods -l app=static-web
```

Anotar los nombres de los 3 pods.

#### Paso 6.2: Eliminar un Pod a propósito

```bash
# Eliminar el primer pod que encuentre
kubectl delete pod -l app=static-web --field-selector=status.phase=Running --wait=false | head -1
```

O eliminar uno específico:
```bash
# Copiar el nombre de un pod del paso anterior y pegarlo aquí:
kubectl delete pod <NOMBRE-DEL-POD>
```

#### Paso 6.3: Observar la auto-curación en tiempo real

```bash
kubectl get pods -l app=static-web -w
```

**Resultado esperado:** Verás cómo el Pod eliminado pasa a `Terminating` y un nuevo Pod se crea automáticamente con estado `ContainerCreating` → `Running`.

```
NAME                                     READY   STATUS        RESTARTS   AGE
static-web-deployment-xxx-aaa            1/1     Running       0          5m
static-web-deployment-xxx-bbb            1/1     Running       0          5m
static-web-deployment-xxx-ccc            1/1     Terminating   0          5m   ← Eliminado
static-web-deployment-xxx-ddd            0/1     ContainerCreating  0     1s   ← Nuevo
static-web-deployment-xxx-ddd            1/1     Running       0          3s   ← Recuperado ✅
```

> Presionar `Ctrl+C` para detener la observación.

#### Paso 6.4: Confirmar que se mantienen 3 réplicas

```bash
kubectl get pods -l app=static-web
```

**Resultado:** Siempre 3 pods en estado `Running`. Esto demuestra el **Self-Healing** de Kubernetes.

---

### FASE 7 — Demostración de GitOps (Cambio desde Git)

Esta fase demuestra que Argo CD detecta cambios en GitHub y los sincroniza automáticamente al clúster.

#### Paso 7.1: Modificar el HTML desde GitHub

1. Ir al repositorio en GitHub: `https://github.com/jhoney787813/gke-gitops-autotrust`
2. Navegar a `app/index.html`
3. Clic en el ícono de lápiz ✏️ (Edit this file)
4. Buscar el texto:
   ```html
   Arquitectura <span ...>GitOps</span> sobre Kubernetes
   ```
5. Cambiar `Kubernetes` por `Kubernetes v2` (o cualquier cambio visible)
6. Clic en **"Commit changes"** con el mensaje: `docs: cambio para demostrar GitOps sync`

#### Paso 7.2: Esperar la sincronización de Argo CD

Argo CD revisa el repositorio cada ~3 minutos por defecto. Puedes forzar la sincronización:

**Desde la terminal de Killercoda:**
```bash
# Forzar sincronización inmediata (sin instalar argocd CLI)
kubectl patch application autotrust-web -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

**O desde la UI de Argo CD:**
1. Abrir Argo CD en el puerto 30007
2. Clic en la Application **"autotrust-web"**
3. Clic en el botón **"SYNC"** → **"SYNCHRONIZE"**

#### Paso 7.3: Verificar el cambio

1. Acceder a la aplicación web en el puerto `32000`
2. El cambio de texto debería reflejarse automáticamente

> ✅ Esto demuestra el ciclo completo de **GitOps**: cambio en Git → Argo CD detecta → sincroniza al clúster → cambio visible en la app.

---

## Resumen de Puertos

| Servicio | Tipo | Puerto | Uso |
|---|---|---|---|
| **Argo CD UI** | NodePort | `30007` | Dashboard de gestión GitOps |
| **Aplicación Web** | NodePort | `32000` | Sitio web estático (nginx) |

## Resumen de Comandos Útiles

```bash
# ── Estado general ──
kubectl get pods -l app=static-web          # Ver las 3 réplicas
kubectl get svc static-web-service          # Ver el Service
kubectl get applications -n argocd          # Ver la Application de Argo CD
kubectl get all -l app=static-web           # Ver todos los recursos

# ── Logs y depuración ──
kubectl logs -l app=static-web --tail=20    # Ver logs de los pods
kubectl describe deployment static-web-deployment  # Detalles del Deployment
kubectl describe application autotrust-web -n argocd  # Detalles de Argo CD

# ── Demostración Self-Healing ──
kubectl delete pod -l app=static-web --wait=false | head -1
kubectl get pods -l app=static-web -w       # Observar la recuperación

# ── Contraseña de Argo CD (si la olvidaste) ──
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

---

## Troubleshooting (Solución de Problemas)

### ❌ El script falla en el Paso 2 (timeout esperando Argo CD)

**Causa:** Los pods de Argo CD tardan más de lo esperado.

**Solución:**
```bash
# Verificar el estado de los pods de Argo CD
kubectl get pods -n argocd

# Si alguno está en CrashLoopBackOff, esperar y reintentar
kubectl rollout restart deployment argocd-server -n argocd
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
```

### ❌ La Application aparece como "OutOfSync"

**Causa:** Los manifiestos en GitHub difieren del estado actual del clúster.

**Solución:**
```bash
# Forzar sincronización
kubectl delete application autotrust-web -n argocd
# Volver a ejecutar el script o crear la Application manualmente
./setup-killercoda.sh
```

### ❌ No se puede acceder al puerto 32000

**Causa:** El Service no se creó correctamente.

**Solución:**
```bash
# Verificar que el Service existe
kubectl get svc static-web-service

# Si no existe, aplicar manualmente
kubectl apply -f manifests/app.yaml
```

### ❌ "Unable to connect to the server" al ejecutar kubectl

**Causa:** El clúster de Killercoda expiró (sesión de ~60 min).

**Solución:** Iniciar un nuevo Playground en Killercoda y repetir desde la Fase 2.

---

## Conceptos Clave Demostrados

| Concepto | Cómo se demuestra |
|---|---|
| **GitOps** | El repositorio GitHub es la fuente de verdad; Argo CD sincroniza automáticamente |
| **Despliegue Declarativo** | Los manifiestos YAML definen el estado deseado, no scripts imperativos |
| **Alta Disponibilidad** | 3 réplicas del Deployment garantizan disponibilidad ante fallos |
| **Self-Healing** | Kubernetes recrea automáticamente los Pods eliminados |
| **Orquestación** | Argo CD gestiona el ciclo de vida completo de la aplicación |
| **Infraestructura como Código** | Toda la infraestructura está versionada en Git |
| **Reconciliación Continua** | Argo CD detecta y corrige drift entre Git y el clúster |

---

> 📝 **Documento generado como guía práctica para la Actividad Formativa — Unidad 3**
> Maestría en Arquitectura de Software · Politécnico Grancolombiano · 2026
