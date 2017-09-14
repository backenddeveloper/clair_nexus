This is a quick demonstration of a private Docker repo using [Nexus OSS](https://www.sonatype.com/nexus-repository-oss), and a demonstration of [Clair](https://github.com/coreos/clair) Docker vulnerability scanner.

This assumes the installation of [Vagrant](https://www.vagrantup.com/) with the default Virtualbox provider.

```bash
apt-get install vagrant virtualbox
```

To see Clair in action run

```bash
vagrant up
vagrant ssh docker
./README.exe
```
