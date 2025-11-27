#!/usr/bin/env python3
"""
AgroSenseAI - Azure Functions Handler (Python version)

This is a lightweight entry point for Azure Functions deployment.
In production, use the Node.js version (function/index.js) which includes full logic.

This Python handler demonstrates:
- Safe environment variable loading
- Payload validation
- Error handling without exposing secrets
- Azure Functions-ready response format

Setup:
1. Copy .env.example to .env and fill in your Azure credentials
2. Set environment variables: source .env  (or in Azure App Settings)
3. Deploy to Azure Functions

For local testing:
  python index.py

For Azure Functions deployment:
  - Use the Node.js version (function/index.js) for full functionality
  - Or extend this file with your business logic
"""

import json
import os
import sys
from typing import Dict, Any, Optional


# ============================================================================
# Configuration Loading
# ============================================================================

def load_config() -> Dict[str, str]:
    """Load configuration from environment variables.
    
    Returns:
        Dict with required and optional configuration keys
        
    Raises:
        ValueError: If critical environment variables are missing
    """
    config = {
        # Azure OpenAI
        'AZURE_OPENAI_KEY': os.getenv('AZURE_OPENAI_KEY', ''),
        'AZURE_OPENAI_ENDPOINT': os.getenv('AZURE_OPENAI_ENDPOINT', ''),
        'AZURE_OPENAI_DEPLOYMENT': os.getenv('AZURE_OPENAI_DEPLOYMENT_NAME', 'gpt-35-turbo'),
        
        # Azure Cognitive Search
        'AZURE_SEARCH_KEY': os.getenv('AZURE_SEARCH_KEY', ''),
        'AZURE_SEARCH_ENDPOINT': os.getenv('AZURE_SEARCH_ENDPOINT', ''),
        
        # Cosmos DB
        'COSMOSDB_CONNECTION': os.getenv('COSMOSDB_CONNECTION_STRING', ''),
        
        # Mode
        'USE_AZURE': os.getenv('USE_AZURE', 'false').lower() == 'true',
        'NODE_ENV': os.getenv('NODE_ENV', 'development'),
    }
    
    return config


def validate_config(config: Dict[str, str], strict: bool = False) -> tuple[bool, Optional[str]]:
    """Validate configuration completeness.
    
    Args:
        config: Configuration dictionary
        strict: If True, require all Azure credentials. If False, allow development mode.
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    if strict and config['USE_AZURE']:
        required = ['AZURE_OPENAI_KEY', 'AZURE_OPENAI_ENDPOINT', 'AZURE_SEARCH_KEY', 'AZURE_SEARCH_ENDPOINT']
        missing = [k for k in required if not config.get(k)]
        if missing:
            return False, f"Missing environment variables: {', '.join(missing)}"
    
    return True, None


# ============================================================================
# Handler Functions
# ============================================================================

def handle_message(payload: Dict[str, Any], config: Dict[str, str]) -> Dict[str, Any]:
    """Process incoming message and return response.
    
    This is a placeholder handler. Replace with your actual business logic.
    
    Args:
        payload: Request payload with 'text' and optional 'language' and 'farmerId'
        config: Configuration dictionary
        
    Returns:
        Response dictionary with 'success', 'message', and optional 'data'
    """
    try:
        # Validate payload
        if not isinstance(payload, dict):
            return {
                'success': False,
                'message': 'Invalid payload: expected JSON object',
                'error': 'INVALID_PAYLOAD'
            }
        
        text = payload.get('text', '').strip()
        language = payload.get('language', 'en').lower()
        farmer_id = payload.get('farmerId', 'anonymous')
        
        if not text:
            return {
                'success': False,
                'message': 'Empty query text',
                'error': 'EMPTY_TEXT'
            }
        
        # Echo for safe testing (replace with real logic)
        if config['USE_AZURE']:
            # TODO: Implement real Azure integration here
            response_text = f"[Azure Mode] Processing query: {text}"
        else:
            # Local/demo mode
            response_text = f"[Demo Mode] Received query from farmer {farmer_id}: {text}"
        
        return {
            'success': True,
            'message': response_text,
            'language': language,
            'farmerId': farmer_id,
            'mode': 'azure' if config['USE_AZURE'] else 'demo'
        }
        
    except Exception as e:
        return {
            'success': False,
            'message': 'Error processing request',
            'error': str(type(e).__name__),
            'details': str(e) if os.getenv('NODE_ENV') == 'development' else None
        }


def main():
    """Entry point for local testing."""
    print("AgroSenseAI - Python Handler")
    print("=" * 50)
    
    # Load config
    config = load_config()
    is_valid, error = validate_config(config, strict=False)
    
    if not is_valid:
        print(f"⚠️  Configuration warning: {error}")
    
    print(f"Mode: {'Azure' if config['USE_AZURE'] else 'Demo'}")
    print(f"Environment: {config['NODE_ENV']}")
    print()
    
    # Test payload
    test_payload = {
        'text': 'What is the price of maize in Kano?',
        'language': 'en',
        'farmerId': 'farmer_001'
    }
    
    print("Test payload:")
    print(json.dumps(test_payload, indent=2))
    print()
    
    # Process
    result = handle_message(test_payload, config)
    
    print("Response:")
    print(json.dumps(result, indent=2))
    print()
    print("✅ Handler executed successfully (ready for Azure Functions deployment)")


if __name__ == '__main__':
    main()
