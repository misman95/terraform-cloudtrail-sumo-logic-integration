# terraform-cloudtrail-sumo-logic-integration
This is a simple TF script for integrating between AWS Cloudtrail and Sumo Logic.
### How it works 
#### this script automatically create the following resources and configurations in AWS and Sumo Logic.
1. Create a new Cloudtrail
2. Create a S3 bucket for cloud trail logs
3. Create a S3 bucket policy
4. Create a IAM role to allow access from Sumo Logic
5. attach iam role policy to the role
6. Create a collector in Sumo Logic
7. Create a source in Sumo Logic
### Reference
You can use the offical TF script developed by Sumo Logic from [here](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/aws/cloudtrail). 
