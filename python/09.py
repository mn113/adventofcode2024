#! /usr/bin/env python3

EMPTY = -1

# Load grid into nested array:
with open('../inputs/input09.txt') as fp:
    input = fp.readlines()[0]

files = []
space_locations = []

# convert to run detailing every separate file block and empty block
def un_rle(data):
    file_id = 0
    res = []
    while len(data):
        runlen, data = int(data[0]), data[1:]
        start = len(res)
        end = start + runlen
        if file_id % 1 == 0:
            files.append({
                'id': int(file_id),
                'start': start,
                'end': end,
                'runlen': runlen
            });
            res += [int(file_id)] * runlen
        else:
            if runlen > 0:
                space_locations.append({
                    'start': start,
                    'end': end,
                    'runlen': runlen
                })
                res += [EMPTY] * runlen
        file_id += 0.5 # half steps are the empty runs, full steps are the files

    return res


# backfill the empty blocks with the last file element one by one
def backfill(data):
    while EMPTY in data:
        last_block = data.pop()
        if last_block == EMPTY:
            continue
        data[data.index(EMPTY)] = last_block
    return data


# move entire files, from highest to lowest, to first available spaces
def defrag(data):
    while len(files):
        if data[-1] == EMPTY:
            data.pop()
            continue
        file = files.pop()
        file_id, file_start, file_end, file_runlen = file["id"], file["start"], file["end"], file["runlen"]
        file_blocks = [file_id] * file_runlen
        space = next((s for s in space_locations if s["runlen"] >= file_runlen and s["start"] < file_start), {"start": -1, "end": -1, "runlen": 0})
        space_start, space_end, space_runlen = space["start"], space["end"], space["runlen"]
        if space_start >= 0:
            # move file blocks into data space
            for i in range(0, file_runlen):
                data[space_start + i] = file_blocks[i]
                data[file_start + i] = EMPTY
            # replace changed space definition
            space_diff = space_runlen - file_runlen
            unfilled_space_start = space_start + file_runlen

            # 333...444...555 - removal of 444 means:
            # eliminate prior space defn
            # eliminate next space defn
            # create space length 9 between 333 and 555
            previous_file_end = file_start - 1
            next_file_start = file_end + 1
            span = next_file_start - previous_file_end
            for k in range(file_start, file_start - 10, -1):
                if data[k] != file_id and data[k] != EMPTY:
                    previous_file_end = k
                    break
            for k in range(file_end, min(len(data), file_end + 10)):
                if data[k] != file_id and data[k] != EMPTY:
                    next_file_start = k
                    break

            for sloc in space_locations:
                # replace changed space definition
                if sloc["start"] == space_start:
                    sloc["start"] = unfilled_space_start
                    sloc["end"] = space_end
                    sloc["runlen"] = space_diff
                    break
                # consolidate the 1-3 space runs where the file blocks were removed
                if sloc["start"] == previous_file_end + 1:
                    sloc["start"] = previous_file_end + 1
                    sloc["end"] = next_file_start - 1
                    sloc["runlen"] = span
                elif sloc["start"] == next_file_start:
                    # zero-lengther will just be ignored from now on
                    sloc["start"] = next_file_start
                    sloc["end"] = next_file_start
                    sloc["runlen"] = 0

    return data


def checksum(data):
    return sum([max(data[i], 0) * i for i in range(len(data))])

un_rle_result = un_rle(input)
un_rle_result2 = un_rle_result[:]

p1 = checksum(backfill(un_rle_result))
print("Part 1:", p1)

p2 = checksum(defrag(un_rle_result2))
print("Part 2:", p2)

# P1: 6366665108136
# P2: 6398065450842
