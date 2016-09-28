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

#ifndef TRAININGLINECORE_H
#define TRAININGLINECORE_H

#include <QDeclarativeItem>

#include <QPointer>

class TrainingStats;

class TrainingLineCore : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(int rabbitSpeed READ rabbitSpeed NOTIFY rabbitSpeedChanged)
    Q_PROPERTY(QDeclarativeItem* cursorItem READ cursorItem WRITE setCursorItem NOTIFY cursorItemChanged)
    Q_PROPERTY(QDeclarativeItem* cursorRabbitItem READ cursorRabbitItem WRITE setCursorRabbitItem NOTIFY cursorRabbitItemChanged)
    Q_PROPERTY(TrainingStats* trainingStats READ trainingStats WRITE setTrainingStats NOTIFY trainingStatsChanged)
    Q_PROPERTY(QString referenceLine READ referenceLine WRITE setReferenceLine NOTIFY referenceLineChanged)
    Q_PROPERTY(QString actualLine READ actualLine NOTIFY actualLineChanged)
    Q_PROPERTY(QString preeditString READ preeditString NOTIFY preeditStringChanged)
    Q_PROPERTY(bool isCorrect READ isCorrect NOTIFY actualLineChanged)
    Q_PROPERTY(QString nextCharacter READ nextCharacter NOTIFY actualLineChanged)
    Q_PROPERTY(int hintKey READ hintKey NOTIFY hintKeyChanged)
public:
    explicit TrainingLineCore(QDeclarativeItem* parent = 0);
    bool active() const;
    int rabbitSpeed() const;
    void setActive(bool active);
    QDeclarativeItem* cursorItem() const;
    QDeclarativeItem* cursorRabbitItem() const;
    void setCursorItem(QDeclarativeItem* cursorItem);
    void setCursorRabbitItem(QDeclarativeItem* cursorRabbitItem);
    TrainingStats* trainingStats() const;
    void setTrainingStats(TrainingStats* trainingStats);
    QString referenceLine() const;
    void setReferenceLine(const QString& referenceLine);
    QString actualLine() const;
    QString preeditString() const;
    bool isCorrect() const;
    QString nextCharacter() const;
    int hintKey() const;
public slots:
    void reset();
signals:
    void activeChanged();
    void rabbitSpeedChanged();
    void cursorItemChanged();
    void cursorRabbitItemChanged();
    void trainingStatsChanged();
    void referenceLineChanged();
    void actualLineChanged();
    void preeditStringChanged();
    void hintKeyChanged();
    void done();
protected:
    void keyPressEvent(QKeyEvent* event);
    void inputMethodEvent(QInputMethodEvent* event);
    QVariant inputMethodQuery(Qt::InputMethodQuery query) const;
private:
    void add(const QString& text);
    void backspace();
    void deleteStartOfWord();
    void clearActualLine();
    void giveKeyHint(int key);
    void clearKeyHint();
    bool m_active;
    TrainingStats* m_trainingStats;
    QString m_referenceLine;
    QString m_actualLine;
    QString m_preeditString;
    int m_hintKey;
    int m_keyHintOccurrenceCount;
    QPointer<QDeclarativeItem> m_cursorItem;
    QPointer<QDeclarativeItem> m_cursorRabbitItem;
};

#endif // TRAININGLINECORE_H
