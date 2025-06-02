package utils

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"

	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/util/yaml"
	"k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/rest"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/envtest"
)

var nilFn = func() error { return nil }

type KubeHelper struct {
	cfg    *rest.Config
	client client.Client
}

func NewKubeHelper(cfg *rest.Config) (*KubeHelper, error) {
	k8sClient, err := client.New(cfg, client.Options{Scheme: scheme.Scheme})
	if err != nil {
		return nil, fmt.Errorf("failed to create Kubernetes client: %w", err)
	}
	return &KubeHelper{
		cfg:    cfg,
		client: k8sClient,
	}, nil
}

// Apply is like `kubectl apply`, but in Golang.
func (k *KubeHelper) Apply(ctx context.Context, path string) error {
	// Install CRDs first
	_, err := envtest.InstallCRDs(k.cfg, envtest.CRDInstallOptions{
		Paths:              []string{path},
		ErrorIfPathMissing: true,
	})
	if err != nil {
		return fmt.Errorf("failed to install CRDs: %w", err)
	}

	// Apply others
	file, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("failed to open file %q: %w", path, err)
	}
	var closeErr error
	defer func() {
		closeErr = file.Close()
	}()

	decoder := yaml.NewYAMLOrJSONDecoder(file, 1024)
	for {
		obj := &unstructured.Unstructured{}
		err = decoder.Decode(&obj)
		if errors.Is(err, io.EOF) {
			break
		} else if err != nil {
			return fmt.Errorf("failed to decode: %w", err)
		} else if obj.Object == nil {
			continue
		}

		_, err = ctrl.CreateOrUpdate(ctx, k.client, obj, nilFn)
		if err != nil {
			return fmt.Errorf("failed to apply: %w", err)
		}
	}

	return closeErr
}

func (k *KubeHelper) GetClient() client.Client {
	return k.client
}
