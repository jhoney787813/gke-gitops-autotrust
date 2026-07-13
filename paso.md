# GitOps AutoTrust CO — Resumen de Cambios

Estructura completa generada para desplegar una aplicación web estática bajo el patrón **GitOps** utilizando **Kubernetes** y **Argo CD** en un clúster real de **Killercoda**.

## Estructura Final

```text
gke-gitops-autotrust/
├── app/
│   └── index.html              ← Sitio web estático (Tailwind CSS CDN)
├── manifests/
│   └── app.yaml                ← Manifiesto unificado (ConfigMap + Deployment + Service)
└── setup-killercoda.sh         ← Script Bash automatizado para Killercoda
```

---

## Archivos Creados / Modificados

### 1. [index.html](file:///Users/deals/Documents/GIT/gke-gitops-autotrust/app/index.html) — Rediseñado

| Aspecto | Detalle |
|---|---|
| Framework CSS | Tailwind CSS v3 vía CDN |
| Diseño | Dark-mode premium con glassmorphism, gradientes animados |
| Secciones | Header sticky · Hero con badge académico · Pipeline GitOps (4 pasos) · Estado de Pods (3 réplicas) · Tarjeta de autoría · Footer |
| Animaciones | `float`, `slide-up`, `pulse-ring`, `gradient-shift` — CSS puro |
| Datos del autor | Jhon Edison Hincapie Garcia, Politécnico Grancolombiano |

### 2. [app.yaml](file:///Users/deals/Documents/GIT/gke-gitops-autotrust/manifests/app.yaml) — Creado (reemplaza `web-deployment.yaml`)

Manifiesto Kubernetes unificado con 3 recursos:

| Recurso | Nombre | Detalles clave |
|---|---|---|
| **ConfigMap** | `web-html-config` | Contiene el HTML completo como dato embebido |
| **Deployment** | `static-web-deployment` | **3 réplicas**, `nginx:alpine`, volume readOnly, resource requests/limits |
| **Service** | `static-web-service` | `NodePort` fijo en **32000** |

> [!IMPORTANT]
> El archivo antiguo `manifests/web-deployment.yaml` fue eliminado para mantener la estructura limpia.

### 3. [setup-killercoda.sh](file:///Users/deals/Documents/GIT/gke-gitops-autotrust/setup-killercoda.sh) — Nuevo

Script Bash automatizado (5 pasos):

| Paso | Acción |
|---|---|
| 1 | Instala Argo CD v2.14.11 en namespace `argocd` |
| 2 | Espera con `kubectl wait` a que el deployment esté disponible |
| 3 | Parchea el servicio `argocd-server` a **NodePort 30007** |
| 4 | Extrae la contraseña inicial del Secret |
| 5 | Crea la `Application` de Argo CD con **auto-sync + selfHeal + prune** apuntando al repo GitHub |

---

## Puertos de Red (Killercoda)

| Servicio | Tipo | Puerto |
|---|---|---|
| Argo CD UI | NodePort | **30007** |
| Aplicación Web | NodePort | **32000** |

## Cómo usar en Killercoda

```bash
# 1. Clonar el repositorio
git clone https://github.com/jhoney787813/gke-gitops-autotrust.git

# 2. Ejecutar el script de configuración
chmod +x setup-killercoda.sh
./setup-killercoda.sh

# 3. Verificar los pods
kubectl get pods -l app=static-web
```

---

## Validación

- ✅ Estructura de directorios coincide con la especificación de la rúbrica
- ✅ 3 réplicas para alta disponibilidad y self-healing
- ✅ NodePort 30007 (Argo CD) y 32000 (App)
- ✅ HTML embebido en ConfigMap — no requiere imagen Docker personalizada
- ✅ Auto-sync + selfHeal + prune habilitados en la Application de Argo CD
- ✅ Script idempotente (`--dry-run=client | kubectl apply`)
