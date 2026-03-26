{ config, pkgs, ... }:

{

  # GRAPHICS & ROCm STACK
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Keep for gaming
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr

    ];
  };

  # GLOBAL ENVIRONMENT & PATH FIXES
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "12.0.1";
    HSA_ENABLE_SDMA_COPY_WAVES = "0";
    ROCM_PATH = "${pkgs.rocmPackages.clr}";
  };

  # 4. OLLAMA SERVICE

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    # Explicitly define the user to avoid evaluation errors
    user = "ollama";
    group = "ollama";

    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "12.0.1";
      OLLAMA_DEBUG = "1";
      HIP_VISIBLE_DEVICES = "0";

      # The "Golden Ratio": 26 GiB in bytes
      # This keeps 32B models in VRAM but saves 6GB for "Compute Buffers"
      OLLAMA_VRAM_OVERRIDE = "27917287424";

      # A solid context window for a 900-file repo map
      OLLAMA_NUM_CTX = "16384";
      OLLAMA_NUM_PARALLEL = "1";


      HSA_ENABLE_SDMA_COPY_WAVES = "0";
      ROCM_PATH = "${pkgs.rocmPackages.clr}";
    };

    # Commented out to pull manually after verification
    # loadModels = [ "qwen2.5-coder:32b" "deepseek-r1:32b" ];
  };

  # 5. USER & PERMISSIONS
  # Ensure the service user and your main user can talk to the hardware
  users.groups.ollama = { }; # Create the group if not already present
  users.users.ollama.extraGroups = [ "video" "render" ];

  # IMPORTANT: Make sure your personal username is also in these groups
  # users.users.alex.extraGroups = [ "video" "render" ];

  # 6. SYSTEM TOOLS & MONITORING
  environment.systemPackages = with pkgs; [
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    nvtopPackages.amd
    clinfo
    aider-chat
    git
    ripgrep
  ];

  # 7. UDEV RULES
  services.udev.extraRules = ''
    KERNEL=="kfd", GROUP="video", MODE="0660"
    KERNEL=="renderD*", GROUP="video", MODE="0660"
  '';
}
