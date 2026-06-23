# redistrib :: { [RedistName] :: { manifest :: Manifest, url :: String } }
builtins.mapAttrs
  (_: value: {
    inherit (value) url;
    manifest = builtins.fromJSON (builtins.readFile (builtins.fetchurl value));
  })
  {
    cublasmp = {
      url = "https://developer.download.nvidia.com/compute/cublasmp/redist/redistrib_0.9.1.json";
      sha256 = "0ibvynrwvpn6dxanirma38kr2pv58rw0n03s4mhzgdpv4cw6riri";
    };
    cuda = {
      url = "https://developer.download.nvidia.com/compute/cuda/redist/redistrib_13.2.1.json";
      sha256 = "10r7l1bq97kcwlz6ccrkg3l7chjq5c0h00vswmbbx8h49x9ldkd4";
    };
    cudnn = {
      url = "https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_9.23.2.json";
      sha256 = "1gh9n5khm4jrkddfxq22lmlf041a0c16aczx32ypms6mplvxsni6";
    };
    cudss = {
      url = "https://developer.download.nvidia.com/compute/cudss/redist/redistrib_0.8.0.json";
      sha256 = "02zs0akw43s7z4s24jchc4j5m5aswrnsvrhj46yhf0bb9hqngkkp";
    };
    cuquantum = {
      url = "https://developer.download.nvidia.com/compute/cuquantum/redist/redistrib_26.03.2.json";
      sha256 = "0ab27m8wms9f997glq9dnzg6xby97yx0nkjiz1hgywgvy0nw215f";
    };
    cusolvermp = {
      url = "https://developer.download.nvidia.com/compute/cusolvermp/redist/redistrib_0.8.0.json";
      sha256 = "0ki924sxiqmhk3mknq86q2yiag4nqrx65djqhw8shq6fj7fjy1n0";
    };
    cusparselt = {
      url = "https://developer.download.nvidia.com/compute/cusparselt/redist/redistrib_0.9.1.json";
      sha256 = "0qmn8z7fidrddrx2fzv1p298h5gm6h576xnhdyv37vfwxxk3rcmy";
    };
    cutensor = {
      url = "https://developer.download.nvidia.com/compute/cutensor/redist/redistrib_2.7.0.json";
      sha256 = "1bpk43b0wj7240j3023xrdqp55y5r3y9xy56rmkszj680h9nq7wq";
    };
    nppplus = {
      url = "https://developer.download.nvidia.com/compute/nppplus/redist/redistrib_0.10.0.json";
      sha256 = "12jz5z5p05y3f6jmdiqgb85kd6kcg304hkkwfvwm9nxi5n48jrw7";
    };
    nvcomp = {
      url = "https://developer.download.nvidia.com/compute/nvcomp/redist/redistrib_5.2.0.json";
      sha256 = "0c87vd43wgs6p5r3s1y9gp1hplvp7zss3a33lb5mcg5v6vvllyxb";
    };
    nvjpeg2000 = {
      url = "https://developer.download.nvidia.com/compute/nvjpeg2000/redist/redistrib_0.10.0.json";
      sha256 = "0l5f54cz7lvsijyw5ms3mh6f8l8ny3knsjfbknlq3wfbwrzp60lg";
    };
    nvpl = {
      url = "https://developer.download.nvidia.com/compute/nvpl/redist/redistrib_26.5.json";
      sha256 = "1g9bwr379fs9smp5p16rsjs8z2sxy7wk0b74aqdsc3mhzhd07cp3";
    };
    nvtiff = {
      url = "https://developer.download.nvidia.com/compute/nvtiff/redist/redistrib_0.7.0.json";
      sha256 = "0s4zsc2lp2s50ckpw0yzzl3j9yl2yf8kv1i45f49l1v3fm6kmmz2";
    };
  }
