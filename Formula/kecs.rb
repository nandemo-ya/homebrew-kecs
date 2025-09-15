class Kecs < Formula
  desc "Kubernetes-based ECS Compatible Service"
  homepage "https://github.com/nandemo-ya/kecs"
  version "0.1.0"
  license "Apache-2.0"

  # URLs will be automatically updated by GitHub Actions
  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/nandemo-ya/kecs/releases/download/v0.1.0/kecs_v0.1.0_Darwin_x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/nandemo-ya/kecs/releases/download/v0.1.0/kecs_v0.1.0_Darwin_arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/nandemo-ya/kecs/releases/download/v0.1.0/kecs_v0.1.0_Linux_x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/nandemo-ya/kecs/releases/download/v0.1.0/kecs_v0.1.0_Linux_arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  depends_on "docker" => :run
  depends_on "k3d" => :run

  def install
    bin.install "kecs"
    
    # Install bash completion
    bash_completion.install "completions/kecs.bash" => "kecs" if File.exist?("completions/kecs.bash")
    
    # Install zsh completion
    zsh_completion.install "completions/kecs.zsh" => "_kecs" if File.exist?("completions/kecs.zsh")
    
    # Install fish completion
    fish_completion.install "completions/kecs.fish" if File.exist?("completions/kecs.fish")
  end

  def post_install
    # Create default data directory
    (var/"kecs").mkpath
  end

  def caveats
    <<~EOS
      KECS has been installed!
      
      To get started:
        kecs start              # Start KECS with a new k3d cluster
        kecs status             # Check status
        kecs tui                # Open interactive TUI
      
      Configure AWS CLI to use KECS:
        export AWS_ENDPOINT_URL=http://localhost:5373
        export AWS_ACCESS_KEY_ID=test
        export AWS_SECRET_ACCESS_KEY=test
        export AWS_REGION=us-east-1
      
      Data is stored in: #{var}/kecs
      
      For more information:
        https://github.com/nandemo-ya/kecs
    EOS
  end

  service do
    run [opt_bin/"kecs", "server", "--data-dir", var/"kecs"]
    keep_alive true
    log_path var/"log/kecs.log"
    error_log_path var/"log/kecs.error.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    # Test version command
    assert_match "kecs version", shell_output("#{bin}/kecs version 2>&1")
    
    # Test help command
    assert_match "Kubernetes-based ECS Compatible Service", shell_output("#{bin}/kecs --help 2>&1")
    
    # Test that binary is executable
    system "#{bin}/kecs", "--help"
  end
end