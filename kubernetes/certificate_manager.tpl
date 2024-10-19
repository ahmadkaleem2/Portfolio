apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - selector:
          dnsZones:
          - "ahmadkaleem2.link"
          - "*.ahmadkaleem2.link"

        dns01:
          route53:
            region: us-east-1 # Specify your AWS region
            hostedZoneID: ${hostedZoneID} # The Route 53 hosted zone ID for your domain
            role: ${role}
            # hostedZoneID: Z06136533TBVAXK89FVB5 # The Route 53 hosted zone ID for your domain
            # role: arn:aws:iam::680688655542:role/cert-manager
            auth:
              kubernetes:
                serviceAccountRef: 
                  name: cert-manager # The name of the service account created