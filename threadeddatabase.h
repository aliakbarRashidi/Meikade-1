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

#ifndef THREADEDDATABASE_H
#define THREADEDDATABASE_H

#include <QThread>

class MeikadeDatabase;
class ThreadedDatabasePrivate;
class ThreadedDatabase : public QThread
{
    Q_OBJECT
public:
    ThreadedDatabase(MeikadeDatabase *pdb, QObject *parent = 0);
    ~ThreadedDatabase();

public slots:
    void initialize();

    void find( const QString & keyword );
    bool next( int length = 100 );

signals:
    void found( int poem_id, int vorder );
    void noMoreResult();

protected:
    void run();

private:
    ThreadedDatabasePrivate *p;
};

#endif // THREADEDDATABASE_H
