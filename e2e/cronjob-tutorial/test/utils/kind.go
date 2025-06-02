package utils

import (
	"fmt"
	"io"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/kind/pkg/cluster"
	"sigs.k8s.io/kind/pkg/cluster/nodeutils"
	"time"
)

const nodeImage = "kindest/node:v1.31.9@sha256:b94a3a6c06198d17f59cca8c6f486236fa05e2fb359cbd75dabbfc348a10b211"

type KindEnvironment struct {
	provider     *cluster.Provider
	name         string
	usesExisting bool
}

func NewKindEnvironment(name string, deadline time.Duration, imageArchives []io.Reader) (*KindEnvironment, error) {
	provider := cluster.NewProvider()

	clusters, err := provider.List()
	if err != nil {
		return nil, fmt.Errorf("failed to list clusters: %w", err)
	}
	exists := false
	for _, existing := range clusters {
		if existing == name {
			exists = true
			break
		}
	}

	if !exists {
		if err := provider.Create(
			name,
			cluster.CreateWithWaitForReady(deadline),
			cluster.CreateWithNodeImage(nodeImage),
		); err != nil {
			return nil, fmt.Errorf("failed to create cluster: %w", err)
		}
	}

	nodes, err := provider.ListNodes(name)
	if err != nil {
		return nil, fmt.Errorf("failed to list nodes: %w", err)
	}

	for _, imageArchive := range imageArchives {
		for _, node := range nodes {
			if err = nodeutils.LoadImageArchive(node, imageArchive); err != nil {
				return nil, fmt.Errorf("failed to load image archive: %w", err)
			}
		}
	}

	return &KindEnvironment{
		provider:     provider,
		name:         name,
		usesExisting: exists,
	}, nil
}

func (k *KindEnvironment) GetClientConfig() (*rest.Config, error) {
	kubeconfig, err := k.provider.KubeConfig(k.name, false)
	if err != nil {
		return nil, fmt.Errorf("failed to get kubeconfig: %w", err)
	}

	restConfig, err := clientcmd.RESTConfigFromKubeConfig([]byte(kubeconfig))
	if err != nil {
		return nil, fmt.Errorf("failed to convert kubeconfig to REST config: %w", err)
	}

	return restConfig, nil
}

func (k *KindEnvironment) Shutdown() error {
	if k.usesExisting {
		return nil
	}
	if err := k.provider.Delete(k.name, ""); err != nil {
		return fmt.Errorf("failed to delete kind cluster: %w", err)
	}
	return nil
}
