# apim-gw-cicd

This umbrella chart installs the jenkins and sonatype-nexus charts to provide a CICD pipeline for Gateway deployment. 

## Install apim-gw-cicd

### Prerequisites
- DNS records are configured for Jenkins and Nexus
- Static IP addresses reserved for Jenkins and Nexus
- TLS secret is present for use by Jenkins Ingress and Nexus Ingress (Refer to cert-manager README.md)

### Download dependencies and install
`helm dep build`

`helm install apim-gw-cicd --name=apim-gw-cicd --values override.yaml`

## sonatype-nexus

[sonatype-nexus](https://github.com/helm/charts/tree/master/stable/sonatype-nexus) provides an artifact repository and private docker registry for CI/CD.
Ingress
```$xslt
  ingress:
    enabled: true
    path: /*
    annotations:
      kubernetes.io/ingress.class: gce
      kubernetes.io/ingress.global-static-ip-name: "apim-nexus-ip"
    tls:
      enabled: true
      secretName: apim-tls
```
## jenkins
[jenkins](https://github.com/helm/charts/tree/master/stable/jenkins) provides a build and automation server for CI/CD.
### Changes to the config.yaml file

Number of Jenkins executors is changed to 1 instead of 0 to be able to automatically build jobs without configuring Jenkins UI.
```
<numExecutors>1</numExecutors>
```

### Changes to the values file

The Ingress for Jenkins is enabled and the Service type has been changed from LoadBalancer to NodePort. This allows association of a domain name with Jenkins:
```
ServiceType: NodePort # change to NodePort once working
HostName: jenkins.example.com

Ingress:
  Path: /*
  Annotations:
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: "apim-jenkins-ip"
  TLS:
    - secretName: apim-tls
      hosts:
        - jenkins.example.com
```

Additional Plugins were added/updated to support Jenkins pipeline, Kubernetes, and using Git as VCS:
```
InstallPlugins:
    - kubernetes:1.13.5
    - workflow-job:2.30
    - workflow-aggregator:2.6
    - credentials-binding:1.16
    - git:3.9.3
    - github-branch-source:2.4.1
```

The number of Executors has been set to 1 (the Jenkins chart default is 0):
```
NumExecutors: 1
```

Initial template job has been added to the values file so customers can just build the job after deploying Jenkins.
Fill in the following to configure the job template:
jenkinsfile_repository_url: this is where the repo which holds the Jenkinsfile is located
```
Jobs: 
    demo-CICD: 
      <?xml version='1.0' encoding='UTF-8'?>
      <flow-definition plugin="workflow-job@2.25">
      <description></description>
      <keepDependencies>false</keepDependencies>
      <properties>
          <com.coravy.hudson.plugins.github.GithubProjectProperty plugin="github@1.29.3">
              <projectUrl>https://github.com/kmienata/puma-ephemeral-gateway-config.git/</projectUrl>
              <displayName></displayName>
          </com.coravy.hudson.plugins.github.GithubProjectProperty>
          <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
              <triggers>
                  <com.cloudbees.jenkins.GitHubPushTrigger plugin="github@1.29.3">
                      <spec></spec>
                  </com.cloudbees.jenkins.GitHubPushTrigger>
              </triggers>
          </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      </properties>
      <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.60">
          <scm class="hudson.plugins.git.GitSCM" plugin="git@3.9.1">
              <configVersion>2</configVersion>
              <userRemoteConfigs>
                  <hudson.plugins.git.UserRemoteConfig>
                      <url><jenkinsfile_repository_url></url>
                  </hudson.plugins.git.UserRemoteConfig>
              </userRemoteConfigs>
              <branches>
                  <hudson.plugins.git.BranchSpec>
                      <name>*/master</name>
                  </hudson.plugins.git.BranchSpec>
              </branches>
              <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
              <submoduleCfg class="list"/>
              <extensions/>
          </scm>
          <scriptPath>Jenkinsfile</scriptPath>
          <lightweight>true</lightweight>
      </definition>
      <triggers/>
      <disabled>false</disabled>
```

In order to enable Jenkins agents to use docker, we are mounting to the docker daemon on the node the container is running on.
```
volumes:
    - name: docker-socket-volume
      hostPath:
        path: /var/run/docker.sock
    - name: docker-binary
      hostPath:
        path: /usr/bin/docker
  mounts:
    - mountPath: /var/run/docker.sock
      name: docker-socket-volume
    - mountPath: /usr/bin/docker
      name: docker-binary
```

To correctly allocate the deployment on a low usage node, memory and cpu requests are increased to tell Kubernetes.
```
requests:
      cpu: "200m"
      memory: "1024Mi"
```