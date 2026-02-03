import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')

def handler(event, context):
    # 1. Find all EBS volumes that are 'available' (not attached to an EC2)
    volumes = ec2.describe_volumes(
        Filters=[{'Name': 'status', 'Values': ['available']}]
    )['Volumes']
    
    if not volumes:
        logger.info("No idle EBS volumes found.")
        return

    for vol in volumes:
        vol_id = vol['VolumeId']
        logger.info(f"Found idle volume: {vol_id}. Taking snapshot...")

        # 2. Create a snapshot before any further action (Data Integrity)
        ec2.create_snapshot(
            VolumeId=vol_id,
            Description=f"Automated backup of idle volume {vol_id}"
        )
        
        # Hero Move: You could add ec2.delete_volume(VolumeId=vol_id) here 
        # to actually save money, but for a demo, a snapshot is safer!
        logger.info(f"Snapshot initiated for {vol_id}")

    return {"status": "success", "volumes_processed": len(volumes)}