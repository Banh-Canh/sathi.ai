import sys
import json
import os
from google import genai

# Simple buffering for stdin to ensure we get complete lines
def main():
    # Handle --list flag to list available models
    if "--list" in sys.argv:
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            print(json.dumps({"error": "GEMINI_API_KEY not found"}), flush=True)
            return

        try:
            client = genai.Client(api_key=api_key)
            models = client.models.list()
            model_list = []
            for m in models:
                name = m.name
                
                if name.startswith("models/"):
                    name = name[7:]
                
                model_data = {"name": name}

                if hasattr(m, 'display_name'):
                    model_data["display_name"] = m.display_name

                model_list.append(model_data)
            
            print(json.dumps(model_list), flush=True)
        except Exception as e:
            print(json.dumps({"error": f"List failed: {str(e)}"}), flush=True)
        return

    api_key = os.environ.get("GEMINI_API_KEY")
    chat = None
    client = None

    if api_key:
        try:
            client = genai.Client(api_key=api_key)
            # bumped to 3-flash-preview
            chat = client.chats.create(model='gemini-flash-latest')
        except Exception as e:
            print(json.dumps({"error": f"Init failed: {str(e)}"}), flush=True)
    else:
        print(json.dumps({"error": "GEMINI_API_KEY not found"}), flush=True)

    # Read lines from stdin
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
            
        try:
            # We assume the input is just the raw text prompt strings for now
            # In a real app, successful JSON parsing is safer
            user_text = line
            
            if not chat:
                print(json.dumps({"error": "Backend not initialized (Check API Key)"}), flush=True)
                continue

            response = chat.send_message(user_text)
            
            # Output structured JSON response
            output = {
                "text": response.text,
                "role": "model"
            }
            print(json.dumps(output), flush=True)
            
        except Exception as e:
            error_out = {"error": str(e)}
            print(json.dumps(error_out), flush=True)

if __name__ == "__main__":
    main()
