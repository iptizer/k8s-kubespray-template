# k8s

This readme documents the deployed infrastructure. The idea is to use sub-folders for each namespace and use this file to document the required steps for deployment.

**Note: Currently always the latest version will be installed. For a real production setup you want to use the `--version` option of helm to apply a specific version. Otherwise an exidential upgrade may break your whole setup.**

**Note2: Currently no encryption or anything is used. But it may be required that credentials need to be saved in this repository. If this is within scope, take a look on [git-crypt](https://github.com/AGWA/git-crypt/blob/master/README.md) or [sops](https://github.com/getsops/sops) to securely save credentials in your repository. Git-crypt is easier to set up, sops has definitly more capabilitities but is also more complex.**

## Cert-manager

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install --create-namespace cert-manager jetstack/cert-manager -n cert-manager -f ./cert-manager/helm_cert-manager.yaml
kubectl get pods -n cert-manager -w
# wait until all pods are running
kubectl apply -f ./cert-manager/cert-manager_issuer.yaml
# check cluster issuers
kubectl get clusterissuer
```

## Ingress

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
  -f ./ingress/helm_ingress.yaml
```

## OpenEBS

```sh
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm upgrade --install --create-namespace -f ./openebs/helm_openebs.yaml openebs --namespace openebs openebs/openebs
# watch pods appearing with the following command
kubectl get pods -n openebs -w
# apply the storage class
kubectl apply -f openebs_storageclass.yaml -n openebs
```

## 