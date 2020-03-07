from modules import app
# 
# model = load_model("imagemodel.h5")
# print("model loading .... plaese wait this might take a while")
app.run(debug=False,host='localhost',port=5000, threaded = False)