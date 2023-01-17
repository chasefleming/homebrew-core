class Shaderc < Formula
  desc "Collection of tools, libraries, and tests for Vulkan shader compilation"
  homepage "https://github.com/google/shaderc"
  license "Apache-2.0"

  stable do
    url "https://github.com/google/shaderc/archive/refs/tags/v2023.1.tar.gz"
    sha256 "8041c6874a085a0f357d7918855f9e39bbeff9313cbeacab28505aa233fc0da2"

    resource "glslang" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/glslang.git",
          revision: "1fb2f1d7896627d62a289439a2c3e750e551a7ab"
    end

    resource "spirv-headers" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/SPIRV-Headers.git",
          revision: "d13b52222c39a7e9a401b44646f0ca3a640fbd47"
    end

    resource "spirv-tools" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/SPIRV-Tools.git",
          revision: "0e6fbba7762c071118b3e84258a358ede31fb609"
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "32a384bc8c303087851d33095fcf5aa00d3ae2398e694984192d7444a43102a8"
    sha256 cellar: :any,                 arm64_monterey: "d5a628d418beca1c5e64c1707de4908b6f89a4e2e4cf959f3ff4a1aa513ba29f"
    sha256 cellar: :any,                 arm64_big_sur:  "1e11618686e65f3f767d6fce64894a0efddc81e48a46fa8a9fbb4f688925aaff"
    sha256 cellar: :any,                 ventura:        "22eb75a448a7a946cd89ddc00f1caf8b80d37b49e1b46a0eeda81264dfb791dc"
    sha256 cellar: :any,                 monterey:       "f927c6d71677fefe0671d211824a847e7221cd547ffe4e81ffda965b8254a96a"
    sha256 cellar: :any,                 big_sur:        "5e0df49d49a8c64950cfc7049efc812ff078ad5d36978956009b1bb4ae9765e0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "aeab02a663b940cd5b25b288afa01ef28ea045aad330e4004736b68aacb1e1a4"
  end

  head do
    url "https://github.com/google/shaderc.git", branch: "main"

    resource "glslang" do
      url "https://github.com/KhronosGroup/glslang.git",
          branch: "master"
    end

    resource "spirv-tools" do
      url "https://github.com/KhronosGroup/SPIRV-Tools.git",
          branch: "master"
    end

    resource "spirv-headers" do
      url "https://github.com/KhronosGroup/SPIRV-Headers.git",
          branch: "master"
    end
  end

  depends_on "cmake" => :build
  depends_on "python@3.11" => :build

  def install
    resources.each do |res|
      res.stage(buildpath/"third_party"/res.name)
    end

    system "cmake", "-S", ".", "-B", "build",
           "-DSHADERC_SKIP_TESTS=ON",
           "-DSKIP_GLSLANG_INSTALL=ON",
           "-DSKIP_SPIRV_TOOLS_INSTALL=OFF",
           "-DSKIP_GOOGLETEST_INSTALL=ON",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <shaderc/shaderc.h>
      int main() {
        int version;
        shaderc_profile profile;
        if (!shaderc_parse_version_profile("450core", &version, &profile))
          return 1;
        return (profile == shaderc_profile_core) ? 0 : 1;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lshaderc_shared"
    system "./test"
  end
end
