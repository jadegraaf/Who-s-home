# Who's home
*An IoT exploration using the Particle Photon*

The system consists of two compoments, the **device** and the **app**

The device is a lamp/ornament placed in the house. The front side of the lamp represents the facades of the houses where the members of a family reside. At 18:00, the **app** will ask the user if they are home through a notification, and if so turn on the light in their 'house'. The members of the family can open the app to see which persons are also home.

The lamp uses a [Particle Photon](https://www.particle.io) to connect to the internet via Wi-Fi and accept commands through the cloud service provided by the manufacturer.

Planned features:
- Using GeoFences to update the status of each member through the app
