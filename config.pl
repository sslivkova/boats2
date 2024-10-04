use constant title => "Cool cards";
use constant output_dir => "./output";
use constant card_output_dir => "cards";
use constant html_filename => "index.html";
use constant html_template => <<'TEMPLATE';
<html>
    <head>
        <title>My Chatbots Page</title>
        <style>
            table {
                width: 100%;
                border: 1px solid;
                border-collapse: collapse;
                text-align: left;
                vertical-align:top;
            }
            td {
                vertical-align: top;
            }
        </style>
    </head>
    <body>
        <h1>Welcome to my page! :)</h1>
        {% do categories %}
        <h2>{% category %}</h2>
        <table>
            <thead>
                <tr>
                    <th>Image</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Creator Notes</th>
                    <th>Greetings</th>
                    <th>Tags</th>
                </tr>
            </thead>
            <tbody>
            {% do cards %}
            <tr>
                <td><img src="{% var href %}" width="150px" height="auto"></td>
                <td>{% var name %}</td>
                <td>{% var description %}</td>
                <td>{% if creator_notes %}
                        {% var creator_notes %}
                    {% end %}
                    {% if !creator_notes %}
                        No notes.
                    {% end %}
                </td>
                <td>
                    <p>{% var first_mes %}</p>
                    {% do alternate_greetings %}
                        <p>{% alternate_greeting %}</p>
                    {% end %}
                </td>
                <td>
                    {% do tags %}
                        {% tag %},
                    {% end %}
                </td>
            </tr>
            {% end %}
            </tbody>
        </table>
        {% end %}
    </body>
</html>
TEMPLATE

1;