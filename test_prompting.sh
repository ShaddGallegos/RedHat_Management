#!/bin/bash
# Test script to simulate prompting inputs
# This will select: 1 (IdM), 2 (Libvirt), and 1 (Insights)

echo "Testing project_prompting role with simulated inputs..."
echo ""
echo "Simulated selections:"
echo "  Platform: 1 (IdM)"
echo "  Infrastructure: 2 (Libvirt)"  
echo "  Integrations: 1 (Red Hat Insights)"
echo ""
echo "All subsequent prompts will use defaults"
echo ""

# Create input file with selections + blanks for defaults
{
  echo "1"      # Platform: IdM
  echo "2"      # Infrastructure: Libvirt
  echo "1"      # Integrations: Insights
  yes "" | head -100  # Blank lines for remaining prompts (use defaults)
} | ansible-playbook system_prompts.yml

echo ""
echo "Generated config at: ~/.ansible/conf/env.yml"
echo ""
echo "=== IdM Settings in generated config ==="
grep -i idm ~/.ansible/conf/env.yml | head -15
