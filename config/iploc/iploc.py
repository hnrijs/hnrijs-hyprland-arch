import requests

def get_ipinfo_data(ip):
    try:
        response = requests.get(f"https://ipinfo.io/{ip}/json")
        response.raise_for_status()
        data = response.json()
        return {
            "IP": data.get("ip"),
            "City": data.get("city"),
            "Region or State": data.get("region"),
            "Country": data.get("country"),
            "Coordinates": data.get("loc"),
            "ISP": data.get("org"),
            "Timezone": data.get("timezone")
        }
    except Exception as e:
        return {"error": f"Failed to get data from ipinfo.io: {str(e)}"}

def main():
    ip = input("Enter IP address: ").strip()
    result = get_ipinfo_data(ip)
    
    if 'error' in result:
        print(f"[ERROR] {result['error']}")
    else:
        for key, value in result.items():
            print(f"{key}: {value}")

if __name__ == "__main__":
    main()
