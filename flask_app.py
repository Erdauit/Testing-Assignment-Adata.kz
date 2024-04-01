from flask import Flask, request, jsonify
import xml.etree.ElementTree as ET

app = Flask(__name__)

def json_to_xml(json_data):
    def parse_data(parent, data):  
        if isinstance(data, dict):  # Если данные являются словарем
            for key, value in data.items():  # проходимся по слвоарю ключ и занчение
                node = ET.SubElement(parent, key) 
                parse_data(node, value) # рекурсия
        elif isinstance(data, list):  #для листа
            for item in data:  
                node = ET.SubElement(parent, 'item')  
                parse_data(node, item)  
        else:  
            parent.text = str(data) 

    root = ET.Element('root')  
    parse_data(root, json_data) 
    return ET.tostring(root, encoding='utf-8') 

@app.route('/json-to-xml', methods=['POST'])
def convert_json_to_xml():
    try:
        json_data = request.json
        if json_data:
            xml_data = json_to_xml(json_data)
            return xml_data, 200, {'Content-Type': 'application/xml'}
        else:
            return jsonify({'error': 'No JSON data provided in the request'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
