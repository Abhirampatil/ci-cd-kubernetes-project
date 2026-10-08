NOTE:After every restart, the public IP changes. You must update 
(1) the GitHub webhook Payload URL
(2) the Jenkins URL (Manage Jenkins → System → Jenkins Location → Jenkins URL, change the IP, and save.)
(3) the browser URLs. An Elastic IP avoids this, but it is billed while allocated 

(reffering to 3) 
(Jenkins dashboard — port 8080
http://NEW_PUBLIC_IP:8080

Your Kubernetes application — port 30080
http://NEW_PUBLIC_IP:30080)

(reffering to 1-2)
The GitHub webhook URL must be updated if it points directly to your changing EC2 IP. If your Jenkins URL setting is only used for generating links, updating it is for accuracy rather than basic access.

restart checklist
1. Start EC2 and copy its new public IPv4 address.
2. SSH into EC2 using that address.
3. Update the GitHub webhook Payload URL to the new Jenkins address.
4. Update Jenkins URL in Manage Jenkins → System.
5. Open Jenkins and your application using the new IP and their respective ports.

HOW TO RUN! 

Start EC2 Instance

IN POWERSHELL

cd to directory where the EC2 key is 

cd $HOME\.ssh
icacls .\cicd-key.pem /inheritance:r  <!--OPTIONAL NOT ACTUALLY BECAUSE ALREADY DONE-->
icacls .\cicd-key.pem /grant:r "$($env:USERNAME):(R)" <!--OPTIONAL SAME HERE -->

SSH INTO EC2 TERMINAL:

ssh -i .\cicd-key.pem ubuntu@YOUR EC2_PUBLIC IP

ssh -i .\cicd-key.pem ubuntu@3.80.162.56

TYPE YES IF NEEDED

Check Kubernetes:


kubectl get nodes
kubectl get pods
kubectl get deployments


ACCESS Jenkins:

http://YOUR_NEW_IPV4_PUBLIC_IP:8080
AND ALSO 
sudo systemctl status jenkins


ACCESS YOUR APPLICATION:

http://YOUR_NEW_IPV4_PUBLIC_IP:30080


THEN SIMPLY DEMONSTRATE BY CHANGING ANYTING INSIDE THE ACTUAL CODE AND THEN SIMPLY PUSHING IT TO THE GITHUB 

BY DOING 

git add .
git commit -m "commit message"
git push origin main




