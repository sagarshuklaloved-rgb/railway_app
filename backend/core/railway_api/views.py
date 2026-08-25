from django.http import JsonResponse

def train_list(request):
    data = {
        "status": "success",
        "message": "RailSaathi Live Data Connected!",
        "trains": [
            {"train_no": "12301", "name": "Rajdhani Express", "time": "10:30 AM", "status": "On Time"},
            {"train_no": "12556", "name": "Gorakhdham Express", "time": "02:15 PM", "status": "Delayed by 15 mins"},
            {"train_no": "12004", "name": "Lucknow Shatabdi", "time": "06:10 AM", "status": "On Time"},
            {"train_no": "22436", "name": "Vande Bharat Express", "time": "03:00 PM", "status": "On Time"},
            {"train_no": "12951", "name": "Mumbai Rajdhani", "time": "05:00 PM", "status": "On Time"},
            {"train_no": "12259", "name": "Sealdah Duronto", "time": "06:40 PM", "status": "Delayed by 30 mins"}
        ]
    }
    response = JsonResponse(data)
    response["Access-Control-Allow-Origin"] = "*"
    return response