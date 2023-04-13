# DevOps Project
# CI/CD Pipeline to Build and Deploy a Java application

Tooluri folosite:
- Git - ca si local version control system
- GitHub - ca si distributor version control system
- Jenkins - ca si continuos integration tool
- Maven - ca si build tool
- Ansible - pentru configuration management si deployment tool
- Docker - pentru containerizare
- MobaXterm - pentru a ma conecta pe instante
- Am creat tot acest environment pe AWS

Pentru realizarea acestui proiect::
- Voi modifica codul local si ii voi da push pe github.
- Cand modificarea ajunge in GitHub, Jenkins ii va da pull codului si ii va da build cu ajutorul lui Maven. 
- Odata ce Jenkins da build codului, genereaza artefacte. 
- Aceste artefacte vor fi copiate in Ansible 	
- Ansible va containeriza aceste artefacte

Step 1: Setup Jenkins server:

- create EC2 instance on AWS; security group with port 8080

- change hostname:

		vi/etc/hostname

- install Java pe instanta deoarece Jenkins este Java based application:

		amazon-linux-extras install epel
		amazon-linux-extras install java-openjdk11

- install Jenkins:

		yum install jenkins
		service jenkins start

- acces jenkins on port 8080
	
- configure Java path

		Manage Jenkins > Global Tool Configuration > Java
    
Step 2: Integrate Maven with Jenkins:
    
- create maven directory under /opt

		mkdir /opt/maven
		cd /opt/maven
		wget https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz
		tar -xvzf apache-maven-3.9.1-bin.tar.gz
		mv apache-maven-3.9.1 maven

- setup Maven environment variables and java path - pentru a putea executa maven din afara directorului unde este instalat 

		vi ~/ .bash_profile
		M2_HOME = /opt/maven
		M2=$M2_HOME/bin
		JAVA_HOME=/usr/lib/jvm/kava-11-openjdk-11.0.12.0.7-0.amxn2.0.2.x86_64
		PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2

- Install Maven plugin on Jenkins console:

		Manage Jenkins > Jenkins Plugins > available > Maven > Install without restart
	
- Configure maven path:

		Manage Jenkins > Global Tool Configuration > Maven
    
Step 3: Setup Dockerhost Environment

- create EC2 instance on AWS security group with port 8080:9000

- change hostname:

		vi/etc/hostname

- install docker:
	
		yum install docker -y
		service docker start

- integrate Docker with Jenkins:
- create user called dockeradmin
	
		useradd dockeradmin
		passwd dockeradmin

- add user to docker group
	
		usermod -aG docker dockeradmin	
		
- enable password based authentication and restart the service: because by default ec2 instances doesn`t allow password based authentification

		vi /etc/ssh/sshd-confing
		service sshd reload
	
- install Publish over SSH plugin - pentru a putea copia artefactele din jenkins in dockerhost

		Manage Jenkins > Manage plugins > Available > Publish over SSH > Install withouw restart
		
- configure Dockerhost in the Jenkins:
		
		Manage Jenkins > Configure System > Publish over SSH > SSH Servers > Add name > Add host name > Add username > Add password > Test connection

- create docker directory:

		cd /opt
		mkdir docker

- give ownership of docker directory to dockeradmin user:

		chown -R dockeradmin:dockeradmin /opt/docker
    
 Step 4: Create Ansible server
 
- create EC2 instance on AWS

- change hostname:

		 vi/etc/hostname

- create ansadmin user:
	
		useradd ansadmin
		passwd ansadmin

- add ansadmin to sudoers:

		visudo 
		ansadmin ALL=(ALL) NOPASSWD: ALL

- enable password based login:

		 vi /etc/ssh/sshd-config

- connect with ansadmin user:

		 sudo su - ansadmin

- generate ssh key: 

		ssh-keygen

- install ansible:

		 sudo amazon-linux-extras install ansible2
     
Step 5: Add Dockerhost to as a slave to Ansible system 

- ON DOCKER HOST:
- create ansadmin user:
	
		userradd ansadmin
		passwd ansadmin

- add ansadmin to sudoers:

		visudo
		ansadmin ALL=(ALL) NOPASSWD: ALL

- ON ANSIBLE server:
- add Dockerhost as a manager node: adding Dockerhost private ip adress into the default inventory file
	
		 vi /etc/ansible/hosts

- copy ansible`s ansadmin user public key into dockerhost ansadmin user:	

		ssh-copy-id [Dockerhost private ip]
		
- test connection:
		
		ansible all -m ping

- make new directory called docker /opt
	
		command: cd /opt
		mkdir docker
	
-give ownership of docker directory to ansadmin user:
	
		sudo chown ansadmin:ansadmin docker
		
- install docker:

		cd/opt/docker
		yum install docker

- add ansadmin to docker group:
	
		usermod -aG docker ansadmin
		service docker start     

- Add Ansible private ip adress into the default inventory file: [ansible] - mention it as a group
	
		 vi /etc/ansible/host

- Copy ansible`s ansadmin public key to the ansible system: - to be able to comunicate with the system

		ssh-copy-id [Ansible private ip]

- Test connection:
	
		ansible all -m ping

- login into DockerHub
		
		docker login
    
Step 6: Integrate Ansible with Jenkins

- Install "Publish over SSH" plugin

		Manage Jenkins > Manage Plugins > Available > Publish over SSH - allready installed
	
- Enable connection between Ansible and Jenkins

		Manage Jenkins > Configure System > Publish over SSH > SSH Servers > Add name > Add host name > Add username > Add password > Test connection
    
Step 7: create Dockerfile:

		cd /opt/docker
		vi Dockerfile
		 

Step 8: create ansible playbook to create docker image and push it intoo dockerhub: 
    
		cd /opt/docker
		vi regapp.yml
		

Step 9: create ansible playbook to create docker container: 

		cd /opt/docker
		vi deploy regapp.yml
		
Step 10: Create Jenkins Job

Step 11: Make changes to the code and commit it to github
