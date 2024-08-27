# Import AWS SDK boto3 and print statement to ensure trigger has been activated
import boto3

print('Loading function')

# Create AWS Glue client variable
glue = boto3.client('glue')

# Establish Lambda function
def lambda_handler(event, context):
    
    # Define a variable that contains the AWS Glue Job Name
    gluejobname="DC-Transactions-Pipeline"
    
    # Leverage runId to start the AWS Glue job run and the status variable to print the current status of the job run
    try:
        runId = glue.start_job_run(JobName=gluejobname)
        status = glue.get_job_run(JobName=gluejobname, RunId=runId['JobRunId'])
        print("Job Status : ", status['JobRun']['JobRunState'])
    
    # If an error occurs, print the error message
    except Exception as error:
        print(error)
        raise error