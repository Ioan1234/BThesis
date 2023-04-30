function likeComment(commentId) {
    event.preventDefault();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4 && xhr.status == 200) {
            var responseJson = JSON.parse(xhr.responseText);
            var likeButton = document.querySelector("button[onclick='likeComment(" + commentId + ")']");
            // Update the like button text and title attributes based on the response
            var likesCount = parseInt(responseJson.likes_count, 10);

            if (isNaN(likesCount)) {
                likesCount = 0;
            }

            if (responseJson.action === "liked") {
                likeButton.innerText = "Liked by " + responseJson.likers.split(", ")[0] + (likesCount > 1 ? " + " + (likesCount - 1) : "");
                likeButton.title = responseJson.likers;
            } else {
                if (likesCount === 0) {
                    likeButton.innerText = "Like";
                    likeButton.title = "";
                } else if (likesCount === 1) {
                    likeButton.innerText = "Liked by " + responseJson.likers;
                    likeButton.title = responseJson.likers;
                } else {
                    likeButton.innerText = "Liked by " + responseJson.likers.split(", ")[0] + " + " + (likesCount - 1);
                    likeButton.title = responseJson.likers;
                }
            }
        }
    };
    xhr.open("POST", "likeComment.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send("comment_id=" + commentId);
}




function deleteComment(commentId) {
    fetch('deleteComment.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'comment_id=' + commentId
    })
        //.then(response=>console.log(response))
        .then(response => response.json())
        .then(jsonResponse => {
            if (jsonResponse.status === 'success') {
                var commentRow = document.getElementById("comment-row-" + commentId);
                if (commentRow) {
                    commentRow.parentNode.removeChild(commentRow);
                    var numCommentsElement = document.getElementById("num-comments");
                    var numComments = parseInt(numCommentsElement.innerText) - 1;
                    numCommentsElement.innerText = numComments;
                    if (numComments == 0) {
                        var table = document.getElementsByTagName("table")[0];
                        table.style.display = "none";
                    }
                }
                console.log("Reloading page...");
                location.reload();

            } else {
                console.error("Failed to delete the comment");
            }
        })
        .catch(error => console.error(error));
}

async function fetchParentCommentText(parentCommentId) {
    const parentCommentElement = document.getElementById("comment-row-" + parentCommentId);
    console.log(`Fetching parent comment text for comment ID ${parentCommentId}`);
    console.log(parentCommentElement);
    console.log("parentCommentText:", parentCommentElement.dataset.parentCommentText);


    if (parentCommentElement) {
        const parentCommentText = parentCommentElement.dataset.parentCommentText;
        console.log(`Fetched parent comment text: ${parentCommentText}`);
        return parentCommentText;
    } else {
        throw new Error(`Parent comment element not found for comment ID ${parentCommentId}`);
    }
}

function showError(errorMessage, replyForm, textarea, submitButton, uploadingMessage) {
    console.error(errorMessage);

    // Remove the uploading message
    replyForm.removeChild(uploadingMessage);

    // Display the textarea and submit button in case of failure
    textarea.style.display = 'block';
    submitButton.style.display = 'inline';

    // Display the error message
    const errorElement = document.createElement('span');
    errorElement.style.color = 'red';
    errorElement.innerText = errorMessage;
    replyForm.appendChild(errorElement);

    // Remove the error message after 5 seconds
    setTimeout(() => {
        replyForm.removeChild(errorElement);
    }, 5000);
}




function createReplyElement(commentId, text, parentCommentText, postedOn, likers, userName, userId, parentCommentId,isUploading = false) {
    const replyElement = document.createElement("tr");
    replyElement.setAttribute("data-user-name", userName);
    replyElement.setAttribute("data-parent-comment-id", parentCommentId);
    replyElement.setAttribute("data-parent-comment-text", parentCommentText); // Add this line
    replyElement.id = "comment-row-" + commentId;

    const replyHeaderText = isUploading ? 'Uploading your comment shortly...' : `${userName} replied to: <i>${parentCommentText}</i>`;
    const replyText = `
    <td width="25%" class="text-secondary" data-reply-header="${parentCommentId}"><span class="text-secondary">${replyHeaderText}</span></td>

    <td width="55%"><i>${text}</i></td>
    <td width="10%">${postedOn}</td>
    <td width="5%"><button type="button" class="btn btn-primary btn-sm" onclick="likeComment(${commentId})" title="${likers}">Like</button></td>
    <td width="5%"><button type="button" class="btn btn-info btn-sm" data-comment-id="${commentId}" data-parent-comment-id="${parentCommentId}" data-parent-comment-text="${parentCommentText}" onclick="replyComment(this)">Reply</button></td>
`;
    replyElement.innerHTML = replyText;

    console.log(replyElement);

    return replyElement;
}




async function replyComment(button) {
    const commentId = button.getAttribute("data-comment-id");
    let replyFormWrapper = document.getElementById("reply-form-wrapper-" + commentId);

    if (!replyFormWrapper) {
        const parentCommentId = button.getAttribute("data-parent-comment-id");
        const parentCommentText = button.getAttribute("data-parent-comment-text");

        const replyForm = document.createElement("form");
        replyForm.id = "reply-form-" + commentId;
        replyForm.innerHTML = `
        <table style="width: 100%;">
        <tr>
            <td colspan="5"><textarea name="content" rows="3" style="width: 100%;" placeholder="Write your reply..."></textarea></td>
        </tr>
        <tr>
            <td colspan="5" style="text-align: right;"><input type="hidden" name="parent_comment_id" value="${commentId}"><button type="submit" class="btn btn-info btn-sm">Submit Reply</button></td>
        </tr>
        </table>
        `;

        replyFormWrapper = document.createElement("div");
        replyFormWrapper.id = "reply-form-wrapper-" + commentId;
        replyFormWrapper.appendChild(replyForm);

        replyForm.addEventListener("submit", async function (event) {
            event.preventDefault();
            const textarea = replyForm.elements['content'];
            const submitButton = replyForm.querySelector('button[type="submit"]');

            // Hide the textarea and submit button
            textarea.style.display = 'none';
            submitButton.style.display = 'none';

            const uploadingMessage = document.createElement('span');
            uploadingMessage.innerText = "Uploading your comment shortly...";
            replyForm.appendChild(uploadingMessage);


            const content = replyForm.elements['content'].value;
            const parentCommentId = replyForm.elements['parent_comment_id'].value;
            const temporaryReplyElement = createReplyElement('temporary', content, '', '', '', '', '', parentCommentId, true);
            const parentCommentRow = document.getElementById("comment-row-" + parentCommentId);

            if (parentCommentRow) {
                parentCommentRow.insertAdjacentElement("afterend", temporaryReplyElement);
            }

            const response = await fetch("submitReply.jsp", {
                method: "POST",
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: `content=${encodeURIComponent(content)}&parent_comment_id=${encodeURIComponent(parentCommentId)}`
            });

            if (response.ok) {
                const replyResult = await response.json();
                console.log("Response:", replyResult);
                console.log("userName:", replyResult.userName);
                console.log("userId:", replyResult.userId);

                if (replyResult.status.trim() === "success") {
                    location.reload();
                } else {
                    showError(replyResult.error, replyForm, textarea, submitButton, uploadingMessage);
                }
            } else {
                showError(`Failed to submit reply. Status: ${response.status}`, replyForm, textarea, submitButton, uploadingMessage);
            }

        });

        const replyFormTableRow = document.createElement("tr");
        const replyFormTableCell = document.createElement("td");
        replyFormTableCell.colSpan = 5;
        replyFormTableCell.appendChild(replyFormWrapper);
        replyFormTableRow.appendChild(replyFormTableCell);

        if (button.parentElement) {
            button.parentElement.parentElement.insertAdjacentElement("afterend", replyFormTableRow);
        }
    } else {
        replyFormWrapper.parentElement.parentElement.remove();
        button.removeAttribute("data-comment-id");
    }
}



async function displayRepliesOnLoad() {
    const replies = document.querySelectorAll("tr[data-parent-comment-id]");
    for (const reply of replies) {
        const parentCommentId = reply.getAttribute("data-parent-comment-id");
        const parentCommentText = reply.getAttribute("data-parent-comment-text");
        const parentCommentRow = document.getElementById("comment-row-" + parentCommentId);

        if (parentCommentRow) {
            parentCommentRow.insertAdjacentElement("afterend", reply); // Change this line
        } else {
            console.warn(`Parent comment row not found for reply ${reply.id}`);
            continue;
        }

        const replyHeader = reply.querySelector(`td[data-reply-header="${parentCommentId}"]`);
        if (replyHeader) {
            const userName = reply.getAttribute("data-user-name");
            replyHeader.innerHTML = `${userName} replied to: <i>${parentCommentText}</i>`;
        } else {
            console.warn(`Reply header element not found for reply ${reply.getAttribute('id')}`);
            console.log(reply);
        }
    }
}


window.addEventListener('DOMContentLoaded', async () => {
    await displayRepliesOnLoad();
});




