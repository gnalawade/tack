---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    k8s-app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: "CriticalAddonsOnly"
        operator: "Exists"
      containers:
        - image: gcr.io/google_containers/cluster-autoscaler:v0.5.1
          name: cluster-autoscaler
          resources:
            limits:
              cpu: 100m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 300Mi
          command:
            - ./cluster-autoscaler
            - --cloud-provider=aws
            - --nodes=1:5:${WORKER_ASG_NAME}
            - --scale-down-delay=1m
            - --skip-nodes-with-local-storage=false
            - --skip-nodes-with-system-pods=false
            - --stderrthreshold=info
            - --v=4
            - --write-status-configmap=true
          env:
            - name: AWS_REGION
              value: ${REGION}
          volumeMounts:
            - name: ssl-certs
              mountPath: /etc/ssl/certs/ca-certificates.crt
              readOnly: true
          imagePullPolicy: "Always"
      volumes:
        - name: ssl-certs
          hostPath:
            path: "/etc/ssl/certs/ca-certificates.crt"
