# GPUArchitectureAWS
Ephemeral GPU Architecture on AWS EKS (Karpenter)

Overview

This project demonstrates the design, operation, and full teardown of an ephemeral, production-grade GPU platform on AWS EKS, using Karpenter to dynamically provision and decommission NVIDIA GPU nodes based on real workload demand.

The core objective was simple and deliberate:

Prove that GPU infrastructure can be powerful, elastic, and cost-controlled—without sitting idle or leaking spend.

This was a self-directed architecture exercise executed outside of employer mandates, modeled after how elite athletes train during the offseason to stay sharp.

Architecture Summary

Amazon EKS (Kubernetes v1.32) as the control plane

Karpenter v1.x for dynamic node provisioning

NVIDIA GPU instances (g4dn / g5) for compute acceleration

GPU-aware scheduling using taints, tolerations, and resource limits

IAM Roles for Service Accounts (IRSA) with dynamic instance profile management

Ephemeral lifecycle: nodes created only when workloads exist and fully terminated when idle

No static GPU nodegroups. No idle burn.

Key Design Decisions

Separation of concerns

EC2NodeClass handled infrastructure identity, networking, and AMIs

NodePool controlled scheduling behavior and lifecycle rules

Explicit GPU control

nvidia.com/gpu resource limits enforced

Taints and tolerations prevented accidental GPU consumption

Cost-first mindset

GPU nodes only existed while pods required them

Average infrastructure cost remained near $2/day during validation

Full teardown discipline

NodeClaims, NodePools, nodegroups, volumes, and the EKS control plane were explicitly destroyed

No orphaned resources left behind

Real-World Challenges Encountered

This project intentionally surfaced non-theoretical problems that don’t appear in tutorials:

IAM permission boundaries blocking dynamic instance profile creation

GPU scheduling conflicts and unschedulable pods

Node registration failures and NotReady states

Karpenter readiness dependencies delaying provisioning

Ensuring teardown completeness to eliminate hidden cost leakage

Each issue was debugged live and resolved at the platform level.

Why This Project Matters

This work reflects how senior cloud and platform engineers actually operate:

Building systems without waiting for assignments

Designing for cost, failure, and cleanup—not just “happy paths”

Debugging IAM, infrastructure, and Kubernetes together

Treating teardown as a first-class architectural concern

This is the same mindset required to safely operate GPU platforms in regulated, cost-sensitive enterprise environments.

Skills Demonstrated

AWS EKS architecture and lifecycle management

Karpenter provisioning internals (NodePools, NodeClaims, EC2NodeClass)

GPU scheduling and Kubernetes resource governance

AWS IAM, IRSA, and instance profile automation

Cost-optimized infrastructure design

Production debugging under live conditions

Status

Project complete.
All resources have been terminated and costs eliminated.
