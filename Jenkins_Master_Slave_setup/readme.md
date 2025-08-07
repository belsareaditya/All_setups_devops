
# 1. Jenkins Master and Worker Node Setup


<img width="940" height="228" alt="image" src="https://github.com/user-attachments/assets/766790d8-b97c-434b-8d59-090a6744aa21" />

## 2. Create Two Instance one for Jenkins-Master and another for Jenkins-agents.
#
- <b id="Jenkins">Install and configure Jenkins (Master machine)</b>
```bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
sudo apt-get update -y
sudo apt-get install jenkins -y
```

## 3. Go the Jenkins-Master security group and Open port 8080.
<img width="944" height="331" alt="image" src="https://github.com/user-attachments/assets/35038378-64cc-4103-9dc6-97ba8f922c2e" />

 
## 4. Now, access Jenkins Master on the browser on port 8080 and configure it.
<img width="944" height="372" alt="image" src="https://github.com/user-attachments/assets/6a0adac6-c7e1-44c4-af39-403b87f16c8c" />


## 5. Copy the path /var/lib/jenkins/secrets/initialAdminPassword on Jenkins-Master to get the password.


```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## 6. Jenkins-worker">Setting up jenkins worker node


## 7. Create a new EC2 instance (Jenkins Worker) with 2CPU, 8GB of RAM (t2.large) and 29 GB of storage and install java on it

```bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y
```


## We have to create public and Private key on Jenkins Master now.

```bash
cd ~/.ssh | ls
```

 ## generate ssh keys (Master machine) to setup jenkins master-slave
  ```bash
  ssh-keygen
  ```





 

`
