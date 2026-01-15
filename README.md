# KubeVote (Pet Project)

## DevOps pet project in which I will deploy a minimal production-ready cluster for the [example-voting-app](https://github.com/dockersamples/example-voting-app) project from Docker Samples

## Branches

- `master` — project overview and example code
- `gitops` — production GitOps setup (ArgoCD, Helm, Terraform)

kubectl run ab-test
--rm -it
--restart=Never
--image=jordi/ab
--
sh -c 'echo "vote=a" > posta && ab -n 1000 -c 50 -p posta -T "application/x-www-form-urlencoded" http://kube-vote-vote:80/'