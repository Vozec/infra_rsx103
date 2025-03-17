# Déploiement Prometheus et Grafana avec Ansible

Ce projet contient une solution automatisée pour déployer Prometheus et Grafana dans des conteneurs Docker à l'aide d'Ansible. Il comprend également la configuration d'un système d'alertes en temps réel et un tableau de bord Grafana personnalisé.

## Structure du projet

```
.
├── README.md                    # Documentation du projet
├── ansible.cfg                  # Configuration Ansible
├── inventory                    # Fichier d'inventaire pour Ansible
└── playbooks                    # Playbooks Ansible
    ├── deploy.yml               # Playbook principal
    └── roles                    # Rôles Ansible
        ├── common               # Rôle pour les configurations communes
        ├── prometheus           # Rôle pour déployer Prometheus
        └── grafana              # Rôle pour déployer Grafana
```

## Prérequis

- Ansible 2.9+
- Docker et Docker Compose installés sur les hôtes cibles
- Accès SSH aux hôtes cibles

## Utilisation

1. Mettre à jour l'inventaire avec les hôtes cibles
2. Exécuter le playbook principal : `ansible-playbook -i inventory playbooks/deploy.yml`

## Fonctionnalités

- Déploiement automatisé de Prometheus et Grafana dans des conteneurs Docker
- Système d'alertes en temps réel pour détecter les services indisponibles
- Tableau de bord Grafana préconfiguré pour visualiser les métriques importantes
