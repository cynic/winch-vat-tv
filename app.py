import os
import json
from flask import Flask, send_file
from flask_cors import CORS,cross_origin

app = Flask(__name__)
app.config['CORS_HEADERS'] = 'Content-Type'
cors = CORS(app, resources={r"/": {"origins": "*"}})

@app.route('/')
def serve_html():
    return app.send_static_file('index.html')

@app.route('/pictures')
@cross_origin(origin='*')
def serve_pictures():
  pictures_folder = 'pictures'  # Replace with the actual path to your pictures folder
  picture_data = []

  for filename in os.listdir(pictures_folder):
    if filename.endswith('.txt'):
      txt_file_path = os.path.join(pictures_folder, filename)

      image_filename = next((file for file in [os.path.splitext(filename)[0] + ext for ext in ['.png', '.jpg', '.jpeg']] if os.path.isfile(os.path.join(pictures_folder, file))), None)

      if image_filename is not None:
        with open(txt_file_path, 'r') as txt_file:
          name = txt_file.readline().strip()
          position = txt_file.readline().strip()
          description = txt_file.readlines() # can be multiple lines

        picture_data.append({
          'position': position,
          'name': name,
          'picture': '/data/' + image_filename,
          'description': description
        })

  return json.dumps(picture_data)

@app.route('/data/<filename>')
def serve_picture(filename):
  pictures_folder = 'pictures'  # Replace with the actual path to your pictures folder
  image_file_path = os.path.join(pictures_folder, filename)

  if os.path.isfile(image_file_path):
    file_extension = os.path.splitext(filename)[1].lower()
    mimetype = 'image/jpeg' if file_extension == '.jpg' or file_extension == '.jpeg' else 'image/png' if file_extension == '.png' else None  # Adjust the mimetype based on the image file type
    if mimetype is not None:
      return send_file(image_file_path, mimetype=mimetype)
    else:
      return 'Invalid file type requested'
  else:
    return 'Picture not found'


