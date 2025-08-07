
## <mark> 1. Jenkins Master and Worker Node Setup <mark>


<img width="940" height="228" alt="image" src="https://github.com/user-attachments/assets/766790d8-b97c-434b-8d59-090a6744aa21" />

## <mark> 2. Create Two Instance one for Jenkins-Master and another for Jenkins-agents. <mark>
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

##  <mark> 3. Go the Jenkins-Master security group and Open port 8080. <mark>
<img width="944" height="331" alt="image" src="https://github.com/user-attachments/assets/35038378-64cc-4103-9dc6-97ba8f922c2e" />

 
## <mark> 4. Now, access Jenkins Master on the browser on port 8080 and configure it. <mark>
<img width="944" height="372" alt="image" src="https://github.com/user-attachments/assets/6a0adac6-c7e1-44c4-af39-403b87f16c8c" />


## 5. Copy the path /var/lib/jenkins/secrets/initialAdminPassword on Jenkins-Master to get the password.


```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## <mark> 6. Jenkins-worker">Setting up jenkins worker node <mark>

<img width="944" height="296" alt="image" src="https://github.com/user-attachments/assets/ea5073bf-5da5-4296-9907-28f7a1749f88" />

#

## <mark> 7. Create a new EC2 instance (Jenkins Worker) with 2CPU, 8GB of RAM (t2.large) and 29 GB of storage and install java on it <mark>

```bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y
```


## <mark> We have to create public and Private key on Jenkins Master now.<mark>

```bash
cd ~/.ssh | ls
```

 ## <mark> generate ssh keys (Master machine) to setup jenkins master-slave <mark>
  ```bash
ssh-keygen
  ```

```bash
cat id_ed25519 
  ```
#
## <mark>Now move to directory where your ssh keys are generated and copy the content of public key and paste to authorized_keys file of the Jenkins worker node <mark>.

<img width="944" height="380" alt="image" src="https://github.com/user-attachments/assets/8c982323-c6c4-4f88-b13a-720cde55b763" />

## Now Start Creating Jenkins-Worker Node Data

#
  - <b>Now, go to the jenkins master and navigate to <mark>Manage jenkins --> Nodes</mark>, and click on Add node </b>
    - <b>name:</b> Node
    - <b>type:</b> permanent agent
    - <b>Number of executors:</b> 2
    - Remote root directory
    - <b>Labels:</b> Node
    - <b>Usage:</b> Only build jobs with label expressions matching this node
    - <b>Launch method:</b> Via ssh
    - <b>Host:</b> \<public-ip-worker-jenkins\>
    - <b>Credentials:</b> <mark>Add --> Kind: ssh username with private key --> ID: Worker --> Description: Worker --> Username: root --> Private key: Enter directly --> Add Private key</mark>
    - <b>Host Key Verification Strategy:</b> Non verifying Verification Strategy
    - <b>Availability:</b> Keep this agent online as much as possible
#
  - And your jenkins worker node is added
  ![image](https://github.com/user-attachments/assets/cab93696-a4e2-4501-b164-8287d7077eef)

## Restart the Jenkins to Properly sync the Node configurations. 



 

`
