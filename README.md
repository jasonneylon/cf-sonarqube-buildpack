# Cloud Foundry SonarQube Buildpack

The `sonarqube-buildpack` is a [Cloud Foundry](https://www.cloudfoundry.org/) buildpack for running [SonarQube](https://www.sonarqube.org/).
It installs java and sonarqube and uses the provided sonar.properties file for configuration.

## Usage

To use this buildpack, specify the URI of this repository when pushing a sonar.properties file to Cloud Foundry.

```bash
$ cf push <APP-NAME> -p sonar.properties -b https://github.com/joscha-alisch/cf-sonarqube-buildpack.git
```

**Important**

You need to specify `SONARQUBE_VERSION` as an environment variable in your manifest.yml or commandline

```yaml
env:
  SONARQUBE_VERSION: '7.1'
```

```bash
cf set-env <APP_NAME> SONARQUBE_VERSION '7.1'
```


## Configuration 

The buildpack automatically configures the port of the SonarQube web ui. Everything else can be configured in your sonar.properties file.
Before starting SonarQube, the buildpack replaces all variables with syntax `${MY_ENV_VARIABLE}` in the file with the corresponding environment variable.
That makes it easy to inject secrets without the need of committing them to git.

Example:
```properties
sonar.jdbc.password=${MY_SUPER_SECRET_PASSWORD}
``` 

and then for example with the cf cli:
```bash
$ cf set-env <APP-NAME> MY_SUPER_SECRET_PASSWORD penguin
```

## Licensing

This buildpack is released under [MIT License](LICENSE).
