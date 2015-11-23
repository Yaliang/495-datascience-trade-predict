import csv
import datetime
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.svm import SVR
from numpy import *
from pylab import *
from sklearn.feature_selection import SelectKBest,chi2
import heapq
import itertools



def get_input(URL):
    with open(URL) as f_in:
        data = csv.reader(f_in)
        get_data = list()
        index = 0
        for row in data:
            if index == 0:
                get_data.append(row)
                index += 1
                continue
            temp = list()
            for k in row:
                temp.append(float(k))
            get_data.append(temp)

    feature = list()
    label = list()

    # print "get_data:",get_data
    for k in get_data[1:11]:
        temp = k[1:26]
        temp_label = k[26]
        feature.append(temp)
        label.append(temp_label)


    test_f = list()
    test_label = list()
    for k in get_data[11:]:
        test_f.append(k[1:26])
        test_label.append(k[26])

    test_f = asarray(test_f)
    test_label = asarray(test_label)

    feature = asarray(feature)
    label = asarray(label)
    return feature, label, test_f, test_label



def get_square_error(data,prediction):
    add = 0
    for index in range(len(data)):
        add += (abs(data[index]-prediction[index]))/data[index]
    return add/len(data)


if __name__ == '__main__':
    feature, label, test_f, test_label = get_input('totalTable.csv')
    print feature.shape

    print "begin"
    all_index = list()
    all_value = list()
    for k in range(1,25):
        all_index.append(k)
        select_top_k_feature = SelectKBest(chi2,k)
        linear = LinearRegression()
        _top = list()

        for data in (select_top_k_feature.fit(feature,label).scores_):
            _top.append(data)
        index = heapq.nlargest(k,range(len(_top)),key = _top.__getitem__)
        test_feature = list()

        print "index_list:",index
        for id_index in range(len(list(test_f))):
            temp = list()
            for id in index:
                temp.append(test_f[id_index][id])
            test_feature.append(temp)
        test_feature = asarray(test_feature)

        predict_value = linear.fit(select_top_k_feature.fit(feature,label).fit_transform(feature,label),label).predict(test_feature)
        value = get_square_error(list(test_label),list(predict_value))
        print value
        all_value.append(value)
    min_error = min(all_value)
    result_num = all_value.index(min_error)
    print all_index[result_num]
