# Istio install

## Istio through banzai-cloud operator

## Kiali

Then just apply the Kiali operator and CRD:
```bash
kubectl -n istio-system apply -f kiali.yaml
```

## Uninstall

```bash
./install-kiali.sh --uninstall-mode true
```