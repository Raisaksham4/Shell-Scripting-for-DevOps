#!/bin/bash

set -e

REGION="ap-south-1"
INSTANCE_TYPE="t3.micro"
KEY_NAME="devops-learning-key"
KEY_FILE="$HOME/.ssh/${KEY_NAME}.pem"
SG_NAME="CLI_SG"

echo "============================================"
echo "AWS CLI Script for Instance Launch"
echo "============================================"

echo "[1/7] Checking AWS CLI..."

if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install it first."
    exit 1
fi

echo "AWS CLI found. Proceeding..."

echo "[2/7] Checking AWS CLI configuration..."

if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS CLI is not configured. Please configure it first."
    exit 1
fi

echo "AWS CLI is configured. Proceeding..."
echo "[3/7] Setting AWS Region..."

aws configure set region "$REGION"
echo "Region set to $REGION."

echo "======================================"
echo "Prerequisites passed!"
echo "======================================"

echo "[4/7] Finding latest Amazon Linux 2023 AMI..."

AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters \
        "Name=name,Values=al2023-ami-*-x86_64" \
        "Name=state,Values=available" \
        "Name=root-device-type, Values=ebs" \
    --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' \
    --output text
)

echo "AMI ID: $AMI_ID"

echo "[5/7] Creating SSH Key Pair..."

mkdir -p "$HOME/.ssh"

if aws ec2 describe-key-pairs \
    --key-names "$KEY_NAME" &> /dev/null; then

    echo "Key pair '$KEY_NAME' already exists. Skipping creation."

    if [[ ! -f "$KEY_FILE" ]]; then
        echo "Key file '$KEY_FILE' not found. Please ensure you have the private key."
        exit 1
    fi
else
    echo "Creating key pair '$KEY_NAME'..."

    aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --query 'KeyMaterial' \
    --output text > "$KEY_FILE"

    chmod 400 "$KEY_FILE"

    echo "Private Key saved to $KEY_FILE"
fi

echo "[6/7] Configuring security group..."
#Get the default VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
    --query 'Vpcs[?IsDefault].VpcId' \
    --output text
)

if [[ -z "$VPC_ID" || "$VPC_ID" == "None" ]]; then
    echo "Error: No default VPC found. Please create a default VPC or specify a VPC ID."
    exit 1
fi

echo "VPC ID: $VPC_ID"

SG_ID=$(aws ec2 describe-security-groups \
    --filters \
        "Name=group-name, Values=$SG_NAME" \
        "Name=vpc-id, Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' \
    --output text
)

if [[ -z "$SG_ID" || "$SG_ID" == "None" ]]; then
    echo "Creating security group '$SG_NAME'..."

    SG_ID=$(aws ec2 create-security-group \
        --group-name "$SG_NAME" \
        --description "Security group for AWS CLI script" \
        --vpc-id "$VPC_ID" \
        --query 'GroupId' \
        --output text
    )
else
    echo "Security group '$SG_NAME' already exists. Skipping creation."
fi

echo "Security Group ID: $SG_ID"

MY_IP=$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')

if [[ -z "$MY_IP" ]]; then
    echo "ERROR: Could not determine public IP."
    exit 1
fi

echo "Your public IP: $MY_IP"

echo "Configuring SSH access..."

if aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr "$MY_IP/32" &> /dev/null; then
    echo "SSH access configured for $MY_IP."
else
    echo "SSH access already configured for $MY_IP or an error occurred."
fi
echo "[7/7] Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --count 1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CLI_Instance_from_Bash_Script}]' \
    --query 'Instances[0].InstanceId' \
    --output text
)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
    echo "Error: Failed to Launch EC2 instance..."
    exit 1
fi
echo "EC2 instance launched successfully!"
echo "Instance ID: $INSTANCE_ID"

echo "Waiting for EC2 instance to enter running state..."

aws ec2 wait instance-running \
    --instance-ids "$INSTANCE_ID"

echo "EC2 instance is now running."

PUBLIC_IP=$(
    aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text
)

if [[ -z "$PUBLIC_IP" || "$PUBLIC_IP" == "None" ]]; then
    echo "Error: Could not retrieve public IP of the instance."
    exit 1
fi

echo "======================================"
echo "EC2 INSTANCE READY"
echo "======================================"
echo "Instance ID : $INSTANCE_ID"
echo "Public IP   : $PUBLIC_IP"

echo "SSH command : ssh -i $KEY_FILE ec2-user@$PUBLIC_IP"
echo "======================================"

echo "Press Y to ssh into the instance or any other key to exit."

read -n 1 -r
echo
if [[ $REPLY == [Yy] ]]; then
    ssh -i $KEY_FILE ec2-user@$PUBLIC_IP
else
    echo "Exiting without SSH."
fi
