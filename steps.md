```bash
#Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```
```bash
#Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg - dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y
```
```bash
terraform init
terraform validate
terraform plan -var-file=variables.tfvars
terraform apply -var-file=variables.tfvars --auto-approve
```

<br>

* Add AWS Credentials
    * Login to your Jenkins server using your browser
    * From the Jenkins dashboard, click on **Manage Jenkins**
    * Open **Manage Credentials** (or **Credentials**, depending on Jenkins UI)
    * Click on **Global** under the available scopes (this is the global credential store)
    * Click **Add Credentials**
    * In the **Kind** dropdown, select **AWS Credentials**
    * Enter the **ID** exactly as required (this ID will be used later inside your Jenkins pipeline)
    * Enter your **AWS Access Key ID**
    * Enter your **AWS Secret Access Key**
    * (Optional) Add a short **Description** to identify the credential
    * Click on **Create** to save the credentials
    * After creation, verify that the AWS credential appears in the **Global credentials list** with the correct ID

<br>

* Add GitHub credentials
    * Since the GitHub repository is **private**, Jenkins needs authentication to access it
    * In real **industry projects**, repositories are almost always private, so this step is mandatory
    * Login to your **Jenkins server**
    * From the dashboard, go to **Manage Jenkins**
    * Click on **Manage Credentials** (or **Credentials**)
    * Open the **Global** credentials store
    * Click **Add Credentials**
    * In the **Kind** dropdown, select **Username with password**
    * Enter your **GitHub username** in the Username field
    * Enter your **GitHub Personal Access Token (PAT)** in the Password field
    * Set a meaningful **ID** (this ID will be referenced in Jenkins jobs or pipelines)
    * (Optional) Add a **Description** for clarity
    * Click **Create** to save the credentials
    * After saving, confirm that the **GitHub credentials appear in the Global credentials list**
