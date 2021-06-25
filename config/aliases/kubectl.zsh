alias k=kubectl
alias ka='_ka(){ kubectl "$@" --all-namespaces; unset -f _ka}; _ka'

alias ky='_ky(){ kubectl "$@" --dry-run=client -o=yaml" }'

alias kaf='kubectl apply -f'
alias kdelf='kubeclt delete -f'

alias keti='kubeclt exec -ti'

# Contexts
alias kctx='k ctx'

# Nodes
alias kgn='k get nodes'
alias kgna='kgp --all-namespaces'
alias kgnw='kgp --watch'
alias kgnwa='kgp --watch --all-namespaces'
alias kgnwide='kgp -o wide'
alias kdesn='k describe nodes'
alias kdeln='k delete pods'

# Pods
alias kgp='k get pods'
alias kgpa='kgp --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwa='kgp --watch --all-namespaces'
alias kgpwide='kgp -o wide'
alias kdesp='k describe pods'
alias kdelp='k delete pods'
alias kgpl='kgp -l'

# Services
alias kgs='k get services'
alias kgsa='kgs --all-namespaces'
alias kgsw='kgs --watch'
alias kgswa='kgs --watch --all-namespaces'
alias kgswide='kgs -o wide'
alias kdess='k describe services'
alias kdels='k delete services'

# Ingress
alias kgi='k get ingress'
alias kgia='kgi --all-namespaces'
alias kgiw='kgi --watch'
alias kgiwa='kgi --watch --all-namespaces'
alias kgiwide='kgi -o wide'
alias kdesi='k describe ingress'
alias kdeli='k delete ingress'

# Namespaces

alias kgns='k get namespaces'
alias kgnsw='kgi --watch'
alias kdesns='k describe ingress'
alias kdelns='k delete ingress'
alias kns="k ns"

# ConfigMaps
alias kgcm='k get configmaps'
alias kgcma='kgcm --all-namespaces'
alias kgcmw='kgcm --watch'
alias kgcmwa='kgcm --watch --all-namespaces'
alias kgcmwide='kgcm -o wide'
alias kdescm='k describe configmaps'
alias kdelcm='k delete configmaps'

# Secrets
alias kgsec='k get secrets'
alias kgseca='kgsec --all-namespaces'
alias kgsecw='kgsec --watch'
alias kgsecwa='kgsec --watch --all-namespaces'
alias kgsecwide='kgsec -o wide'
alias kdessec='k describe secrets'
alias kdelsec='k delete secrets'

# Deployments
alias kgd='k get deployment'
alias kgda='kgd --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwa='kgd --watch --all-namespaces'
alias kgdwide='kgd -o wide'
alias kdesd='k describe deployment'
alias kdeld='k delete deployment'
alias kscaled='k scale deployment'
alias krsd='k rollout status deployment'

# PersistentVolumes
alias kgpv='k get pv'
alias kgpva='kgpv --all-namespaces'
alias kgpvw='kgpv --watch'
alias kgpvwa='kgpv --watch --all-namespaces'
alias kgpvwide='kgpv -o wide'
alias kdespv='k describe pv'
alias kdelpv='k delete pv'

# PersistentVolumeClaims
alias kgpvc='k get pvc'
alias kgpvca='kgpvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kgpvcwa='kgpvc --watch --all-namespaces'
alias kgpvcwide='kgpvc -o wide'
alias kdespvc='k describe pvc'
alias kdelpvc='k delete pvc'

# Rollout stuff
alias kgrs='k get replicaset'
alias kgrsa='kgrs --all-namespaces'
alias kgrsw='kgrs --watch'
alias kgrswa='kgrs --watch --all-namespaces'
alias kgrswide='kgrs -o wide'
alias kdesrs='k describe replicaset'
alias kdelrs='k delete replicaset'

alias krhist='k rollout history'


# Statefulsets
alias kgss='k get statefulset'
alias kgssa='kgss --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswa='kgss --watch --all-namespaces'
alias kgsswide='kgss -o wide'
alias kdesss='k describe statefulset'
alias kdelss='k delete statefulset'
alias kscaless='k scale statefulset'
alias krsss'k rollout status statefulset'





# Port forward
alias kpfw='k port-forward'

# ALL
alias kga='k get all'
alias kgaa='kga --all-namespaces'
alias kgaw='kga --watch'
alias kgawa='kga --watch --all-namespaces'

# Logs
alias klog='k logs'
#  Seconds
alias klog1s='k logs --since 1s'
alias klog5s='k logs --since 5s'
alias klog10s='k logs --since 10s'
alias klog30s='k logs --since 10s'
#  Seconds + follow
alias klog1sf='k logs --since 1s -f'
alias klog5sf='k logs --since 5s -f'
alias klog10sf='k logs --since 10s -f'
alias klog30sf='k logs --since 10s -f'
#  Minutes
alias klog1m='k logs --since 1m'
alias klog5m='k logs --since 5m'
alias klog10m='k logs --since 10m'
alias klog30m='k logs --since 10m'
#  Minutes + follow
alias klog1mf='k logs --since 1m -f'
alias klog5mf='k logs --since 5m -f'
alias klog10mf='k logs --since 10m -f'
alias klog30mf='k logs --since 10m -f'
#  Hours
alias klog1h='k logs --since 1h'
alias klog5h='k logs --since 5h'
alias klog10h='k logs --since 10h'
#  Hours + follow
alias klog1hf='k logs --since 1h -f'
alias klog5hf='k logs --since 5h -f'
alias klog10hf='k logs --since 10h -f'




