# ☁️ NAS Financial Group Cloud Migration (In Progress)

This project demonstrates how to design and automate a **multi-tier AWS infrastructure** for a dynamic web application using **Terraform**.  
It represents a real-world migration scenario for the **NAS Financial Group**, focusing on scalability, security, and automation.  

The current phase focuses on **infrastructure provisioning** using Terraform.  
Future iterations will include **end-to-end CI/CD automation** with **GitHub**, **Terraform**, and **Jenkins**.

---

## 🚧 Current Progress (Terraform Infrastructure)

The following AWS resources have been successfully provisioned and tested using Terraform:

- ✅ **VPC** with public and private subnets across multiple Availability Zones  
- ✅ **Internet Gateway**, **NAT Gateway**, and **Route Tables** for networking  
- ✅ **Security Groups** for ALB, EC2, RDS, and EFS  
- ✅ **IAM Roles and Policies** for least-privilege access  
- ✅ **Application Load Balancer (ALB)** for distributing traffic  
- ✅ **Auto Scaling Group** with Launch Template (Apache + PHP)  
- ✅ **RDS (MySQL)** database for WordPress  
- ✅ **EFS (Elastic File System)** for shared application storage  

All infrastructure is defined using a **modular Terraform structure** for flexibility and reusability.

---

## 🧩 Project Structure

modules/
├── iam/
├── network/
├── dynamic_web/
└── static_site/


Upcoming modules will include:
- **Monitoring** (CloudWatch, SNS)
- **Storage** (S3 lifecycle management)
- **Automation** (Jenkins pipeline integration)

---

## ⚙️ Technologies Used

| Category | Tools / Services |
|-----------|------------------|
| **IaC** | Terraform |
| **Compute** | EC2, Auto Scaling |
| **Database** | RDS (MySQL) |
| **Storage** | EFS |
| **Networking** | VPC, Subnets, NAT Gateway, ALB |
| **Security** | IAM, Security Groups |
| **CI/CD** | Jenkins (planned) |
| **Monitoring** | CloudWatch (planned) |

---

## 🧠 Next Steps

- Implement **CloudWatch monitoring and alerting**  
- Add **S3 storage and lifecycle management**  
- Integrate **Jenkins** for automated deployment pipeline  
- Configure WordPress and EFS using **Ansible**

---

## 👩🏽‍💻 Author

**Lala Aicha Kallo**  
AWS Cloud Engineer | DevOps Enthusiast  
📍 Silver Spring, MD  
🌐 [linkedin.com/in/lalaakallo11](https://linkedin.com/in/lalaakallo11)  
💻 [github.com/lalacloudspace](https://github.com/lalacloudspace)

---

> 💡 *This repository represents the Terraform foundation for a real-world AWS migration project. Additional automation and monitoring features will be added in upcoming phases.*
