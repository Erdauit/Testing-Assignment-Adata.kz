from flask import Flask, request, jsonify
import xml.etree.ElementTree as ET

app = Flask(__name__)

def json_to_xml(json_data):
    def parse_dict(parent, data):
        for key, value in data.items():
            if isinstance(value, dict):
                node = ET.SubElement(parent, key)
                parse_dict(node, value)
            elif isinstance(value, list):
                for item in value:
                    node = ET.SubElement(parent, key)
                    parse_dict(node, item)
            else:
                node = ET.SubElement(parent, key)
                node.text = str(value)

    root = ET.Element('root')
    parse_dict(root, json_data)
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