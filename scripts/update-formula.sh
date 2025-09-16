#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] VERSION

Update Homebrew formula to a new version.

Arguments:
  VERSION     Version to update to (e.g., 0.0.1-alpha, 0.1.0, 1.0.0-rc.1)

Options:
  -f, --formula FORMULA   Formula to update (kecs, kecs-dev, or both) [default: kecs]
  -s, --skip-download     Skip downloading files for SHA256 calculation
  -p, --placeholder       Use PLACEHOLDER for SHA256 (for testing)
  -h, --help             Show this help message

Examples:
  $0 0.0.1-alpha
  $0 --formula kecs-dev 0.0.2-beta
  $0 --formula both 1.0.0
  $0 --placeholder 0.0.1-dev  # For unreleased versions

EOF
    exit 1
}

# Parse arguments
FORMULA="kecs"
SKIP_DOWNLOAD=false
USE_PLACEHOLDER=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--formula)
            FORMULA="$2"
            shift 2
            ;;
        -s|--skip-download)
            SKIP_DOWNLOAD=true
            shift
            ;;
        -p|--placeholder)
            USE_PLACEHOLDER=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

# Check if version is provided
if [ -z "$VERSION" ]; then
    print_error "Version is required"
    usage
fi

# Remove 'v' prefix if present
VERSION="${VERSION#v}"

# Validate version format
if ! echo "$VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?$' > /dev/null; then
    print_error "Invalid version format: $VERSION"
    print_info "Expected format: X.Y.Z or X.Y.Z-prerelease"
    print_info "Examples: 0.0.1, 1.0.0, 0.0.1-alpha, 1.0.0-beta.1"
    exit 1
fi

print_info "Updating formula to version: v$VERSION"

# Define platforms
declare -A PLATFORMS=(
    ["darwin_amd64"]="Darwin_x86_64"
    ["darwin_arm64"]="Darwin_arm64"
    ["linux_amd64"]="Linux_x86_64"
    ["linux_arm64"]="Linux_arm64"
)

# Calculate SHA256 hashes
declare -A SHA256_HASHES

if [ "$USE_PLACEHOLDER" = true ]; then
    print_warn "Using PLACEHOLDER for SHA256 hashes"
    for key in "${!PLATFORMS[@]}"; do
        SHA256_HASHES[$key]="PLACEHOLDER"
    done
elif [ "$SKIP_DOWNLOAD" = false ]; then
    print_info "Calculating SHA256 hashes..."
    
    for key in "${!PLATFORMS[@]}"; do
        FILENAME="kecs_v${VERSION}_${PLATFORMS[$key]}.tar.gz"
        URL="https://github.com/nandemo-ya/kecs/releases/download/v${VERSION}/${FILENAME}"
        
        echo -n "  ${PLATFORMS[$key]}: "
        
        if curl -sL -f "$URL" -o "/tmp/${FILENAME}" 2>/dev/null; then
            SHA256=$(sha256sum "/tmp/${FILENAME}" | cut -d' ' -f1)
            SHA256_HASHES[$key]="$SHA256"
            echo "$SHA256"
            rm "/tmp/${FILENAME}"
        else
            print_warn "Failed to download ${FILENAME}, using PLACEHOLDER"
            SHA256_HASHES[$key]="PLACEHOLDER"
        fi
    done
else
    print_info "Skipping SHA256 calculation"
    for key in "${!PLATFORMS[@]}"; do
        SHA256_HASHES[$key]="EXISTING"
    done
fi

# Function to update formula file
update_formula() {
    local formula_file="$1"
    
    if [ ! -f "$formula_file" ]; then
        print_error "Formula file not found: $formula_file"
        return 1
    fi
    
    print_info "Updating $formula_file"
    
    # Create backup
    cp "$formula_file" "${formula_file}.bak"
    
    # Update version
    sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$formula_file"
    
    # Update URLs
    sed -i '' "s|download/v[^/]*/kecs_v[^_]*_Darwin_x86_64|download/v${VERSION}/kecs_v${VERSION}_Darwin_x86_64|" "$formula_file"
    sed -i '' "s|download/v[^/]*/kecs_v[^_]*_Darwin_arm64|download/v${VERSION}/kecs_v${VERSION}_Darwin_arm64|" "$formula_file"
    sed -i '' "s|download/v[^/]*/kecs_v[^_]*_Linux_x86_64|download/v${VERSION}/kecs_v${VERSION}_Linux_x86_64|" "$formula_file"
    sed -i '' "s|download/v[^/]*/kecs_v[^_]*_Linux_arm64|download/v${VERSION}/kecs_v${VERSION}_Linux_arm64|" "$formula_file"
    
    # Update SHA256 hashes if not skipping
    if [ "$SKIP_DOWNLOAD" = false ]; then
        # This is complex due to multiline structure, so we use a Ruby script
        ruby -e "
            content = File.read('$formula_file')
            lines = content.split(\"\\n\")
            
            lines.each_with_index do |line, i|
                if line.include?('Darwin_x86_64')
                    (i+1..i+3).each do |j|
                        if lines[j] && lines[j].include?('sha256')
                            lines[j] = '      sha256 \"${SHA256_HASHES[darwin_amd64]}\"'
                            break
                        end
                    end
                elsif line.include?('Darwin_arm64')
                    (i+1..i+3).each do |j|
                        if lines[j] && lines[j].include?('sha256')
                            lines[j] = '      sha256 \"${SHA256_HASHES[darwin_arm64]}\"'
                            break
                        end
                    end
                elsif line.include?('Linux_x86_64')
                    (i+1..i+3).each do |j|
                        if lines[j] && lines[j].include?('sha256')
                            lines[j] = '      sha256 \"${SHA256_HASHES[linux_amd64]}\"'
                            break
                        end
                    end
                elsif line.include?('Linux_arm64')
                    (i+1..i+3).each do |j|
                        if lines[j] && lines[j].include?('sha256')
                            lines[j] = '      sha256 \"${SHA256_HASHES[linux_arm64]}\"'
                            break
                        end
                    end
                end
            end
            
            File.write('$formula_file', lines.join(\"\\n\"))
        "
    fi
    
    # Validate Ruby syntax
    if ruby -c "$formula_file" > /dev/null 2>&1; then
        print_info "✅ Formula syntax is valid"
        rm "${formula_file}.bak"
    else
        print_error "Formula syntax validation failed!"
        mv "${formula_file}.bak" "$formula_file"
        return 1
    fi
}

# Update the specified formula(s)
case $FORMULA in
    kecs)
        update_formula "Formula/kecs.rb"
        ;;
    kecs-dev)
        update_formula "Formula/kecs-dev.rb"
        ;;
    both)
        update_formula "Formula/kecs.rb"
        update_formula "Formula/kecs-dev.rb"
        ;;
    *)
        print_error "Invalid formula: $FORMULA"
        print_info "Valid options: kecs, kecs-dev, both"
        exit 1
        ;;
esac

print_info "Formula update complete!"
print_info ""
print_info "Next steps:"
print_info "  1. Review the changes: git diff"
print_info "  2. Commit the changes: git add -A && git commit -m \"chore: Update $FORMULA to v$VERSION\""
print_info "  3. Push to repository: git push origin main"