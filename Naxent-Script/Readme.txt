How to Run Deployment Script for Test, Development, and Production
==================================================================

1. Open PuTTY and connect to the EC2 instance.

2. Navigate to the deployment script directory:

   cd /home/ec2-user/naxent-config/scripts/www.naxent.in

3. Run the script with the desired environment name:

   For Test:
      ./deploy-latest-from-s3.sh test

   For Development:[Currently We Are Not Using This Development Deployment Script]
      #./deploy-latest-from-s3.sh development

   For Production:
       ./deploy-latest-from-s3.sh production
