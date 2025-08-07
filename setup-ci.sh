#!/bin/bash

# Chatas CI Setup Script
# Script này giúp setup GitHub Actions workflows cho dự án Flutter (chỉ CI)

set -e

echo "🚀 Setting up Chatas CI..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from your project root."
    exit 1
fi

# Check if .github directory exists
if [ ! -d ".github" ]; then
    print_error ".github directory not found. Please ensure GitHub Actions workflows are set up."
    exit 1
fi

print_status "GitHub Actions workflows found!"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

print_status "Flutter installation found: $(flutter --version | head -1)"

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in a Flutter project?"
    exit 1
fi

print_status "Flutter project detected!"

# Run flutter doctor to check setup
print_info "Running Flutter doctor to check setup..."
flutter doctor

# Check if tests pass
print_info "Running tests to verify project state..."
if flutter test; then
    print_status "All tests passed!"
else
    print_warning "Some tests failed. You may want to fix them before setting up CI/CD."
fi

# Validate GitHub Actions workflows
print_info "Validating GitHub Actions workflows..."

workflows=(".github/workflows/ci.yml" ".github/workflows/cd.yml" ".github/workflows/pr-check.yml")
for workflow in "${workflows[@]}"; do
    if [ -f "$workflow" ]; then
        print_status "Found: $workflow"
    else
        print_error "Missing: $workflow"
    fi
done

# Setup checklist
echo ""
echo "🔧 Setup Checklist:"
echo ""
echo "1. GitHub Repository Setup:"
echo "   □ Repository is on GitHub"
echo "   □ Workflows are committed and pushed"
echo "   □ Branch protection rules configured"
echo ""
echo "2. Firebase Setup (for deployment):"
echo "   □ Firebase project created"
echo "   □ App Distribution enabled"
echo "   □ Firebase Hosting enabled"
echo "   □ Service account created with Editor permissions"
echo ""
echo "3. GitHub Secrets Setup:"
echo "   Required secrets in GitHub repository settings:"
echo "   □ FIREBASE_APP_ID"
echo "   □ FIREBASE_PROJECT_ID" 
echo "   □ FIREBASE_SERVICE_ACCOUNT_KEY"
echo ""
echo "4. Android Signing (for production):"
echo "   □ Keystore file created"
echo "   □ ANDROID_KEYSTORE_BASE64"
echo "   □ ANDROID_KEY_ALIAS"
echo "   □ ANDROID_KEY_PASSWORD"
echo "   □ ANDROID_STORE_PASSWORD"
echo ""

# Check current git status
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes. Consider committing them:"
    echo ""
    git status --short
    echo ""
    read -p "Do you want to commit and push the workflow files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .github/
        git commit -m "ci: add GitHub Actions workflows for CI/CD

- Add CI workflow for testing and building
- Add CD workflow for deployment to Firebase
- Add PR check workflow for code quality
- Add Dependabot configuration
- Add issue and PR templates"
        
        print_info "Pushing to remote repository..."
        git push
        print_status "Workflows committed and pushed!"
    fi
else
    print_status "Repository is clean!"
fi

# Final instructions
echo ""
print_info "🎉 Setup completed!"
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Navigate to Settings > Secrets and variables > Actions"
echo "3. Add the required secrets listed above"
echo "4. Create a test branch and push to trigger CI"
echo "5. Create a tag (e.g., v1.0.0) to trigger CD"
echo ""
echo "For detailed instructions, see .github/workflows/README.md"
echo ""
print_status "Happy coding! 🚀"
