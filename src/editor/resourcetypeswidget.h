/*
 *  Copyright 2012  Sebastian Gottfried <sebastiangottfried@web.de>
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation; either version 2 of
 *  the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef RESOURCETYPESWIDGET_H
#define RESOURCETYPESWIDGET_H

#include <QWidget>
#include "ui_resourcetypeswidget.h"

#include "models/resourcemodel.h"

class QStandardItemModel;

class ResourceTypesWidget : public QWidget, private Ui::ResourceTypesWidget
{
    Q_OBJECT
public:
    explicit ResourceTypesWidget(QWidget* parent = 0);
signals:
    void typeSelected(ResourceModel::ResourceItemType type);
private slots:
    void currentRowChanged(const QModelIndex& current);
private:
    QStandardItemModel* m_typesModel;
};

#endif // RESOURCETYPESWIDGET_H
