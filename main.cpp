/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <QIcon>

#include "meikade.h"
#include "sialantools/sialanapplication.h"

int main(int argc, char *argv[])
{
    SialanApplication app(argc, argv);
    app.setApplicationName("Meikade");
    app.setApplicationDisplayName("Meikade");
    app.setOrganizationDomain("org.sialan.meikade");
    app.setOrganizationName("Sialan");
    app.setWindowIcon(QIcon(app.applicationDirPath()+"/qml/Meikade/icons/meikade.png"));

    Meikade meikade;
    meikade.start();

    return app.exec();
}
