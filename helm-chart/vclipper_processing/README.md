# java

Java standard chart definition to deploy applications on Kubernetes.

## [Configuration](#configuration)
-----

| **Parameter**                      	    | **Description**                                                                                                 	    | **Type**  	|
|---------------------------------------  |---------------------------------------------------------------------------------------------------------------------- |-----------	|
| **`SERVICE.TYPE`**                 	    | Kubernetes Service Type                                                                                         	    | str       	|
| **`SERVICE.PORT`**                     	| Exposed Port from the Kubernetes Service                                                                        	    | int       	|
| **`SERVICE.LOAD_BALANCER.ENABLED`**    	| If **true**, creates an extra Kubernetes Service with suffix **-lb** and a Load Balancer                           	  | bool      	|
| **`SERVICE.LOAD_BALANCER.DNS_SUFFIX`** 	| Requires **SERVICE.LOAD_BALANCER.ENABLED: true** - DNS address which will be attached to the Load Balancer            | str       	|
| **`INGRESS.ENABLED`**                  	| If **true**, creates an ingress for the Kubernetes Service                                                         	  | bool      	|
| **`INGRESS.HOST`**                    	| Ingress hostname for Kubernetes Service                                                                             	| str        	|
| **`INGRESS.PATH`**                     	| Requires **INGRESS.ENABLED: true** - Path used in ingress. Ex: your.ingress.vpc**/say/Hello**                         | str       	|
| **`DEPLOYMENT.REPLICAS`**              	| Amount of replicas for the Kubernetes deployment                                                                  	  | int       	|
| **`DEPLOYMENT.PORT`**                  	| Container port for the Kubernetes deployment                                                                     	    | int       	|
| **`DEPLOYMENT.ENV.ENABLED`**           	| If **true**, enables Kubernetes Deployment to search environment variables from Kubernetes **APP_NAME** secrets      	| bool      	|
| **`DEPLOYMENT.ENV.VARS`**              	| Requires **DEPLOYMENT.ENV.ENABLED: true** - List of variables to be searched from Kubernetes **APP_NAME** secrets     | list<str> 	|
| **`RESOURCES.MIN.CPU`**                	| Minimum CPU required to run the container                                                                       	    | str       	|
| **`RESOURCES.MIN.RAM`**                	| Minimum RAM required to run the container                                                                       	    | str       	|
| **`RESOURCES.MAX.CPU`**                	| Maximum CPU required to run the container                                                                       	    | str       	|
| **`RESOURCES.MAX.RAM`**                	| Maximum CPU required to run the container                                                                       	    | str       	|
| **`IMAGE`**                            	| Container image used inside Kubernetes Deployment                                                               	    | str       	|


## [Example](#example)
-----

#### yourvalues.yaml
```yaml
# Github Action adds IMAGE automatically, but you can set normally

IMAGE: 171219910203199431032017/snackbar:v1.0.0

SERVICE:
    TYPE: ClusterIP
    PORT: 80
    LOAD_BALANCER:
      ENABLED: false
      DNS_SUFFIX: api.snackbar.com.br

INGRESS:
    ENABLED: false
    PATH: /say/Hello

DEPLOYMENT:
    REPLICAS: 2
    PORT: 8080
    ENV:
      ENABLED: true

    RESOURCES:
      MIN:
        CPU: 100m
        RAM: 64Mi
      MAX:
        CPU: 500m
        RAM: 64Mi
```

# Changelog

- 28/06/2025 - Started helm chart project