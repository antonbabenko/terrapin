from jinja2 import nodes
from jinja2.ext import Extension

from pprint import pprint
import json, os, re

class TerraformExtension(Extension):
    tags = set(['get_argument', 'get_attributes'])

    def __init__(self, environment):
        super(TerraformExtension, self).__init__(environment)

    # Returns argument (for "variables") for "prefix" + "type" + "name" + "argument"
    # input example: "resource" "aws_security_group" "name" "Type"
    def _get_argument(self, prefix, type, name, argument):

        data_dir = os.getenv('PYTHON_TF_MODULE_RESOURCES_DIR', '/Users/Bob/Sites/tf-module-generator/resources')
        data_dir = os.path.join(data_dir, 'providers')

        if prefix == 'resource':
            source = 'resources'
        elif prefix == 'data':
            source = 'data-sources'
        else:
            raise ValueError("Unknown prefix %s" % prefix)

        # aws_security_group => aws
        provider_type = re.search(r"^([^_]+)", type).group(0)

        files = []
        for data_file in [f for f in os.listdir(data_dir) if f.endswith('.json')]:
            if data_file.startswith(provider_type):
                files.insert(0, data_file)
            else:
                files.append(data_file)

        # print(files)

        for data_file in files:
            filename = os.path.join(data_dir, data_file)

            input_file = open(filename, 'r')
            json_data = json.load(input_file)

            for item in json_data[source][type][name]:
                try:
                    if item["name"] == argument:
                        return item["value"]
                except KeyError:
                    raise

        raise ValueError("'%s' in %s.%s.%s was not found! Bug in json data, probably." % (argument, prefix, type, name))

    # Returns list of attributes (for "outputs") for "prefix" + "type"
    # input example: "resource" "aws_security_group"
    def _get_attributes(self, prefix, type):

        data_dir = os.getenv('PYTHON_TF_MODULE_RESOURCES_DIR', '/Users/Bob/Sites/tf-module-generator/resources')
        data_dir = os.path.join(data_dir, 'providers_doc')

        if prefix == 'resource':
            source = 'resources'
        elif prefix == 'data':
            source = 'datas'
        else:
            raise ValueError(json.dumps(prefix))

        # aws_security_group => aws + security_group
        match = re.search(r"^([^_]+)_(.+)", type)
        provider_type = match.group(1)
        key = match.group(2)

        files = []
        for data_file in [f for f in os.listdir(data_dir) if f.endswith('.json')]:
            if data_file.startswith(provider_type):
                files.insert(0, data_file)
            else:
                files.append(data_file)

        # print(files)

        for data_file in files:
            filename = os.path.join(data_dir, data_file)

            input_file = open(filename, 'r')
            json_data = json.load(input_file)

            items = []
            try:
                for item in json_data[source][key]['attributes']:
                    items.append(item["word"])
            except KeyError:
                continue

            return ",".join([str(x) for x in items])

        raise ValueError("%s.%s was not found. Probably a misspelling error. Or bug in json data." % (prefix, type))

    def parse(self, parser):
        stream = next(parser.stream)

        lineno = stream.lineno

        node = parser.parse_expression().items

        if stream.value == "get_attributes":
            call_method = self.call_method(
                '_get_attributes',
                [node[0], node[1]],
                lineno=lineno,
            )
        elif stream.value == "get_argument":
            call_method = self.call_method(
                '_get_argument',
                [node[0], node[1], node[2], node[3]],
                lineno=lineno,
            )
        else:
            raise NotImplementedError("Not implemented: %s" % stream.value)

        return nodes.Output([call_method], lineno=lineno)
