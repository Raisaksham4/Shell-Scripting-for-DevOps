#!/bin/bash

REGION="ap-south-1"

echo "======================================"
echo "      Sacnning EC2 Instances"
echo "======================================"

INSTANCE_IDS=$(aws ec2 describe-instances \
    --region "$REGION" \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text)

if [[ -z "$INSTANCE_IDS" ]]; then
    echo "No running EC2 instances found."
    exit 0
fi

echo "Running instances:"
echo "$INSTANCE_IDS"

echo ""
echo "Instance details:"
echo ""

aws ec2 describe-instances \
    --region "$REGION" \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,IP:PublicIpAddress}' \
    --output table

echo ""

echo "Do you want to proceed with stopping all running instances? (yes/no)"
read confirmation

if [[ "$confirmation" != "yes" ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "====================================================================="
echo "Enter 1 to stop all Instances or Enter 2 to stop particular Instance"
read option

if [[ "$option" == "2" ]]; then
    echo "Enter the Instance ID to stop:"
    read instance_id_to_stop

    if [[ ! " $INSTANCE_IDS " =~ " $instance_id_to_stop " ]]; then
        echo "Error: Instance ID $instance_id_to_stop is not in the list of running instances."
        exit 1
    fi

    INSTANCE_IDS="$instance_id_to_stop"
fi


echo "======================================"
echo "Stopping running instances..."
echo "======================================"


aws ec2 stop-instances \
    --region "$REGION" \
    --instance-ids $INSTANCE_IDS

if [[ $? -eq 0 ]]; then
    echo "All running instances have been requested to stop."
else
    echo "ERROR: Failed to stop instances."
    exit 1
fi